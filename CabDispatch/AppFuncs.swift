//
//  AppFuncs.swift
//  CabDispatch
//
//  Created by Dylan on 5/11/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation
    
func buildStringFromDictionary(data : Dictionary<String, AnyObject>, root : String?) -> String {
        var returnString : String
        if let checkRoot = root {
            returnString = root!
        } else {
            returnString = ""
        }
        
        for(key, value) in data {
            returnString += "\(key)"
            if let checkValue = value as? Dictionary<String, AnyObject> {
                returnString = buildStringFromDictionary(checkValue, returnString)
            } else {
                returnString += "\(value)"
            }
            
        }
        
        return returnString
}

func convertNSDictionaryToSwiftDictionary(dictionary : NSDictionary) -> Dictionary<String, AnyObject> {
    
    var dictionaryToReturn = Dictionary<String, AnyObject>()
    
    for key : AnyObject in dictionary.allKeys {
        if let k = key as? String, v: AnyObject = dictionary.objectForKey(key) {
            dictionaryToReturn[k] = v
        } else {
            dictionaryToReturn["Casting Error"] = "Derp"
        }
    }
    
    return dictionaryToReturn
}

func buildCoordsFromLocationDictionary(location : Dictionary<String, AnyObject>) -> CLLocationCoordinate2D {
    
    let latSign = location["Latitude_sign"] as! String
    let longSign = location["Longitude_sign"] as! String
    var lat = location["Latitude"] as! Double
    var long = location["Longitude"] as! Double
    
    if(latSign == "-") {
        lat *= -1
    }
    
    if(longSign == "-") {
        long *= -1
    }
    
    return CLLocationCoordinate2DMake(lat, long)
}