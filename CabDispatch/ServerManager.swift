//
//  ServerManager.swift
//  CabDispatch
//
//  Created by Dylan on 5/2/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let globalServerManager = ServerManager()

class ServerManager {
    
    var deviceID : String?
    
    
    class var defaultManager : ServerManager {
        return globalServerManager
    }
    
    init() {
        
    }
    
    func setDeviceID(deviceID : String) {
        self.deviceID = deviceID
    }
    
    func sendRequest(controller : String, action : [AnyObject], params : Dictionary<String, String>?, requestBody : Dictionary<String, AnyObject>?) -> NSDictionary {
        
        let controllerAction = action[1] as! String
        let requestType = action[0] as! String
        var returnObject : NSDictionary? = nil
        var isDone : Bool = false
        
        var url : NSMutableURLRequest = NSMutableURLRequest(URL: buildURL(controller, action: controllerAction, params: params))
        url.HTTPMethod = requestType
        
        var sentURL = buildURL(controller, action: controllerAction, params: params)
        println("URL: \(sentURL)")
        
        if let checkForBody = requestBody {
            if(action.count > 2) {
                var error : NSError?
                url.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody!, options: nil, error: &error)
            }
        }
        
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(url, completionHandler: {data, response, error -> Void in
            
            //println("\(response)")
            //println("\(data)")
            
            var err : NSError?
            var responseString : NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var stringLength : Int = responseString!.length
            responseString = responseString?.substringToIndex(stringLength - 1)
            responseString = responseString?.substringFromIndex(1)
            
            if let responseObject  = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &err) as? NSDictionary {
                returnObject = responseObject
                println("Dictionary get")
            } else if let responseObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &err) as? NSArray {
                var holderDictionary = NSMutableDictionary()
                var count = responseObject.count
                
                for(var counter = 0; counter < count; counter++) {
                    if let checkDictionary = responseObject[counter] as? Dictionary<String, AnyObject> {
                        //println("Object: \(checkDictionary)")
                        if let checkCustomer = checkDictionary["Customer"] as? Dictionary<String, AnyObject>, checkDestination = checkDictionary["Destination"] as? Dictionary<String, AnyObject> {
                            var fare = Dictionary<String, AnyObject>()
                            fare["Location"] = checkCustomer["Location"]
                            fare["Destination"] = checkDictionary["Destination"]
                            let user = checkDictionary["Customer_ID"] as! Int
                            let userAsString : String = "\(user)"
                            fare["UserID"] = userAsString
                            var id = checkDictionary["FareNumber"] as! Int
                            var key = "\(id)"
                            holderDictionary.setValue(fare, forKey: key)
                            //println("Response is now: \(returnObject!)")
                            
                            //println("Dictionary: \(checkDictionary)")
                            /*var location = checkDictionary["Location"] as? Dictionary<String, AnyObject>
                            println("Location: \(location!)")*/
                            //println("Fare get")
                            //println("Fare: \(fare)")
                        } else {
                            var key = "Driver\(counter)"
                            holderDictionary.setValue(responseObject[counter], forKey: key)
                            //println("Object: \(responseObject[counter])")
                            println("Driver get")
                            //println("Response is now: \(returnObject!)")
                        }
                    }
                    
                }
                println("Array get")
                returnObject = holderDictionary
                
            } else {
                //println("String: \(responseString!)")
                var backToData = responseString?.dataUsingEncoding(NSUTF8StringEncoding)
                if let toJson = NSJSONSerialization.JSONObjectWithData(backToData!, options: .MutableContainers, error: nil) as? NSMutableDictionary {
                    returnObject = toJson
                } else {
                    returnObject = NSMutableDictionary()
                    
                    returnObject?.setValue(responseString!, forKey: "Message")
                    println("Message get")
                }
                
            }
            
            
            if(err != nil) {
                returnObject = NSMutableDictionary()
                returnObject!.setValue("You done messed up", forKey: "Error")
                println("Error get: \(err?.localizedDescription)")
                //println("Response: \(response)")
            }
        })
        
        task.resume()
        
        while (returnObject == nil) {
            
        }
        
        return returnObject!
    }
    
    func updateCustomer(phone : String?, email : String?, location : CLLocation) {
        
            
            let requestInfo = AppConstants.ControllerActions.PatchCustomer
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            
            let customerObject = buildCustomerJSON(location, phone: phone, email: email)
            var response = sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject) as! NSMutableDictionary
        
        postUpdateNotifications(phone, email: email, userID: nil, deviceID: nil)
            // check for 200?
        
    }
    
    func createCustomer(phone : String?, email : String?, location : CLLocation) -> Dictionary<String, AnyObject> {
        
        let requestInfo = AppConstants.ControllerActions.CreateCustomer
        var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        
        var customerObject = buildCustomerJSON(location, phone: phone, email: email)
        var response = sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject) as! NSMutableDictionary
        
        
        if let unwrapDictionary = response["Driver0"] as? Dictionary<String, AnyObject> {
            
            if let checkForDictionary = unwrapDictionary["UserID"] as? Int {
                var id = "\(checkForDictionary)"
                postUpdateNotifications(phone, email: email, userID: id, deviceID: nil)
            }
        } else {
            response.setObject("SubmitFailed", forKey: "Error")
        }
        
        var returnObject = convertNSDictionaryToSwiftDictionary(response)
        if(returnObject["Casting Error"] != nil) {
            returnObject["Error"] = "SubmitFailed"
        }
        
        return returnObject
        
    }
    
    func createDriver(location : CLLocation) -> Dictionary<String, AnyObject> {
        let requestInfo = AppConstants.ControllerActions.CreateDriver
        var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        var driverObject = buildDriverJSON(location)
        var response = sendRequest(AppConstants.ServerControllers.Driver, action: actionArray, params: nil, requestBody: driverObject) as! NSMutableDictionary
        if let unwrapDictionary = response["Driver0"] as? Dictionary<String, AnyObject> {
            if let checkForDictionary = unwrapDictionary["UserID"] as? Int {
                
                postUpdateNotifications(nil, email: nil, userID: "\(checkForDictionary)", deviceID: nil)
            }
        } else {
            response.setObject("SubmitFailed", forKey: "Error")
        }
        
        var returnObject = convertNSDictionaryToSwiftDictionary(response)
        
        if(returnObject["Casting Error"] != nil) {
            returnObject["Error"] = "SubmitFailed"
        }
        
        return returnObject
    }
    
    func updateDriver(location : CLLocation) {
        let requestInfo = AppConstants.ControllerActions.PatchDriver
        var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        var driverObject = buildDriverJSON(location)
        var response = sendRequest(AppConstants.ServerControllers.Driver, action: actionArray, params: nil, requestBody: driverObject)
    }
    
    func allFares() -> Dictionary<String, AnyObject> {
        
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.AllFares
        let actions = [action.0, action.1]
        
        var dictionaryToReturn = sendRequest(controller, action: actions, params: nil, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
    
    func requestFare(location: CLLocation, destination : CLLocation, phone : String?, email : String?, userID : String?) {
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.RequestFare
        let actions = [action.0, action.1, action.2]
        
        
        var dictionaryToReturn : Dictionary<String, AnyObject> = sendRequest(controller, action: actions as [AnyObject], params: nil, requestBody: buildFareRequestJSON(location, destination: destination, customerID: userID, phone: phone, email: email)) as! Dictionary<String, AnyObject>
    }
    
    func acceptFare(fareID : String, driverID : String) {
        
        let controller = AppConstants.ServerControllers.Driver
        let action = AppConstants.ControllerActions.AcceptFare
        let actions = [action.0, action.1]
        var params = Dictionary<String, String>()
        params["driverID"] = driverID
        params["customerID"] = fareID
        var response = sendRequest(controller, action: actions, params: params, requestBody: nil)
        //println("Response: \(response)")
    }
    
    func getAssignedFares(driverID : String, orderedBy : String) -> Dictionary<String, AnyObject> {
        
        let controller = AppConstants.ServerControllers.Driver
        let action = AppConstants.ControllerActions.GetCustomerLocations
        let actions = [action.0, action.1]
        
        var params = Dictionary<String, String>()
        
        params["driverID"] = driverID
        
        params["orderedBy"] = orderedBy
        
        var dictionaryToReturn = sendRequest(controller, action: actions, params: params, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
    
    func buildURL(controller : String, action : String, params : Dictionary<String, String>?) -> NSURL {
        
        var baseURL : String = AppConstants.ServerDomains.DispatchAPI
        baseURL += controller
        baseURL += action
        
        if let checkParams = params {
            for (param, value) in params! {
                baseURL += param
                baseURL += "="
                baseURL += value
                baseURL += "&"
            }
            
            baseURL = baseURL.substringToIndex(baseURL.endIndex.predecessor())
        }
        
        
        
        return NSURL(string: baseURL)!
    }
    
    func buildLocationJSON(location : CLLocation) -> Dictionary<String, AnyObject> {
        var locationDictionary = Dictionary<String, AnyObject>()
        
        locationDictionary["Longitude"] = fabs(location.coordinate.longitude)
        locationDictionary["Latitude"] = fabs(location.coordinate.latitude)
        
        if(location.coordinate.latitude >= 0.0) {
            locationDictionary["Latitude_sign"] = "+"
        } else {
            locationDictionary["Latitude_sign"] = "-"
        }
        
        if(location.coordinate.longitude >= 0.0) {
            locationDictionary["Longitude_sign"] = "+"
        } else {
            locationDictionary["Longitude_sign"] = "-"
        }
        
        return locationDictionary
    }
    
    func buildCustomerJSON(location : CLLocation, phone : String?, email : String?) -> Dictionary<String, AnyObject> {
        var customerDictionary = Dictionary<String, AnyObject>()
        
        customerDictionary["Location"] = buildLocationJSON(location)
        
        if let checkPhone = phone {
            customerDictionary["PhoneNumber"] = phone!
        }
        
        if let checkEmail = email {
            customerDictionary["Email"] = email!
        }
        
        if let checkDeviceID = deviceID {
            customerDictionary["deviceID"] = deviceID!
        }
        
        return customerDictionary
    }
    
    func buildDriverJSON(location : CLLocation) -> Dictionary<String, AnyObject> {
        var driverDictionary = Dictionary<String, AnyObject>()
        
        driverDictionary["Location"] = buildLocationJSON(location)
        
        if let checkDeviceID = deviceID {
            driverDictionary["deviceID"] = deviceID!
        }
        
        return driverDictionary
    }
    
    func buildFareRequestJSON(location: CLLocation, destination : CLLocation, customerID : String?, phone : String?, email : String?) -> Dictionary<String, AnyObject> {
        var fareDictionary = Dictionary<String, AnyObject>()
        
        var customerDictionary = buildCustomerJSON(location, phone: phone, email: email)
        
        if let checkUserID = customerID {
            customerDictionary["UserID"] = customerID!
            fareDictionary["Customer_ID"] = customerID!
        }
        
        fareDictionary["Customer"] = customerDictionary
        fareDictionary["Destination"] = buildLocationJSON(destination)
        
        return fareDictionary
    }
    
    func postUpdateNotifications(phone : String?, email : String?, userID : String?, deviceID : String?) {
        println("Updates posted")
        
        if let checkPhone = phone {
            NSNotificationCenter.defaultCenter().postNotificationName("phoneNumberChanged", object: nil, userInfo: ["phone" : phone!])
        }
        
        if let checkEmail = email {
            NSNotificationCenter.defaultCenter().postNotificationName("emailChanged", object: nil, userInfo: ["email" : email!])
        }
        
        if let checkUserID = userID {
            println("ID Notification posted")
            NSNotificationCenter.defaultCenter().postNotificationName("userIDChanged", object: nil, userInfo: ["id" : userID!])
        }
        
        if let checkDeviceID = deviceID {
            NSNotificationCenter.defaultCenter().postNotificationName("deviceIDChanged", object: nil, userInfo: ["id" : deviceID!])
        }
    }
    
    func buildLocationParams(location : CLLocation) -> Dictionary<String, String> {
        
        var paramsToReturn = Dictionary<String, String>()
        
        
        paramsToReturn["Latitude"] = "\(abs(location.coordinate.latitude))"
        paramsToReturn["Longitude"] = "\(abs(location.coordinate.longitude))"
            
        if(location.coordinate.latitude >= 0) {
            paramsToReturn["Latitude_sign"] = "%2B"
        } else {
            paramsToReturn["Latitude_sign"] = "%2D"
        }
            
        if(location.coordinate.longitude >= 0) {
            paramsToReturn["Longitude_sign"] = "%2D"
        } else {
            paramsToReturn["Longitude_sign"] = "%2B"
        }
        
        return paramsToReturn
    }
}