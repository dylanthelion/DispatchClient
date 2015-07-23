//
//  APIObjectBuilder.swift
//  CabDispatch
//
//  Created by Dylan on 5/15/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let sharedBuilder = APIObjectBuilder()

class APIObjectBuilder {
    
    
    init() {
        
    }
    
    class var defaultBuilder : APIObjectBuilder {
        return sharedBuilder
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
    
    func buildCustomerJSON(location : CLLocation, phone : String?, email : String?, deviceID : String?) -> Dictionary<String, AnyObject> {
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
    
    func buildDriverJSON(location : CLLocation, deviceID : String?) -> Dictionary<String, AnyObject> {
        var driverDictionary = Dictionary<String, AnyObject>()
        
        driverDictionary["Location"] = buildLocationJSON(location)
        
        if let checkDeviceID = deviceID {
            driverDictionary["deviceID"] = deviceID!
        }
        
        return driverDictionary
    }
    
    func buildFareRequestJSON(location: CLLocation, destination : CLLocation, customerID : String?, phone : String?, email : String?, deviceID : String?) -> Dictionary<String, AnyObject> {
        var fareDictionary = Dictionary<String, AnyObject>()
        
        var customerDictionary = buildCustomerJSON(location, phone: phone, email: email, deviceID: deviceID)
        
        if let checkUserID = customerID {
            customerDictionary["UserID"] = customerID!
            fareDictionary["Customer_ID"] = customerID!
        }
        
        fareDictionary["Customer"] = customerDictionary
        fareDictionary["Destination"] = buildLocationJSON(destination)
        
        return fareDictionary
    }
    
    func jsonArrayToDictionary(array : NSArray) -> NSDictionary {
        
        let holderDictionary = NSMutableDictionary()
        let count = array.count
        
        for(var counter = 0; counter < count; counter++) {
            if let checkDictionary = array[counter] as? Dictionary<String, AnyObject> {
                
                if let checkCustomer = checkDictionary["Customer"] as? Dictionary<String, AnyObject>, checkDestination = checkDictionary["Destination"] as? Dictionary<String, AnyObject> {
                    
                    var fare = Dictionary<String, AnyObject>()
                    fare["Location"] = checkCustomer["Location"]
                    fare["Destination"] = checkDictionary["Destination"]
                    let user = checkDictionary["Customer_ID"] as! Int
                    let userAsString : String = "\(user)"
                    fare["UserID"] = userAsString
                    let id = checkDictionary["FareNumber"] as! Int
                    let key = "\(id)"
                    holderDictionary.setValue(fare, forKey: key)
                } else {
                    let key = "Driver\(counter)"
                    holderDictionary.setValue(array[counter], forKey: key)
                    print("Driver get")
                }
            }
            
        }
        return holderDictionary
    }
    
    func jsonMessageStringToDictionary(data: NSData!) -> NSDictionary {
        
        var returnObject = NSMutableDictionary()
        var responseString : NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let stringLength : Int = responseString!.length
        responseString = responseString?.substringToIndex(stringLength - 1)
        responseString = responseString?.substringFromIndex(1)
        let backToData = responseString?.dataUsingEncoding(NSUTF8StringEncoding)
        
        if let toJson = NSJSONSerialization.JSONObjectWithData(backToData!, options: .MutableContainers) as? NSMutableDictionary {
            returnObject = toJson
        } else {
            returnObject = NSMutableDictionary()
            
            returnObject.setValue(responseString!, forKey: "Message")
        }
        
        return returnObject
    }
}