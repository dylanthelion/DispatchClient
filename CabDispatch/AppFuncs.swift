//
//  AppFuncs.swift
//  CabDispatch
//
//  Created by Dylan on 5/11/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation

    
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