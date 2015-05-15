//
//  APIFuncs.swift
//  CabDispatch
//
//  Created by Dylan on 5/15/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

class APIFuncs {
    
    init() {
        
    }
    
    class func buildURL(controller : String, action : String, params : Dictionary<String, String>?) -> NSURL {
        
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
    
    class func buildLocationParams(location : CLLocation) -> Dictionary<String, String> {
        
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