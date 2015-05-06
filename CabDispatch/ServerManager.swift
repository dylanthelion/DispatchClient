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
            println("\(data)")
            
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
                println("Error get")
            }
        })
        
        task.resume()
        
        while (returnObject == nil) {
            
        }
        
        //println("Return: \(returnObject!)")
        return returnObject!
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
}