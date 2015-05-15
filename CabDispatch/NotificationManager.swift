//
//  NotificationManager.swift
//  CabDispatch
//
//  Created by Dylan on 5/15/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let sharedManager = NotificationManager()

class NotificationManager {
    
    init() {
        
    }
    
    class var defaultManager : NotificationManager {
        return sharedManager
    }
    
    func postAccountUpdateNotifications(phone : String?, email : String?, userID : String?, deviceID : String?) {
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
}