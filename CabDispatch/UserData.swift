//
//  UserData.swift
//  CabDispatch
//
//  Created by Dylan on 5/2/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

private let globalUserData = UserData()

class UserData : NSObject {
    
    var userID : String?
    var deviceID : String?
    var phone : String?
    var email : String?
    let fileManager = NSFileManager.defaultManager()
    let notificationManager = NotificationManager.defaultManager
    
    // used to preload maps
    var currentLocation : CLLocation?
    
    class var getData : UserData {
        return globalUserData
    }
    
    override init() {
        super.init()
        
        loadUserData()
        setUpNotifications()
        deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
        
    notificationManager.postAccountUpdateNotifications(nil, email: nil, userID: nil, deviceID: deviceID)
        
        
    }
    
    func setUpNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: "deviceIDChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: "userIDChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: "emailChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: "phoneNumberChanged", object: nil)
    }
    
    func handleNotification(notification : NSNotification) {
        
        var data = notification.userInfo as! Dictionary<String, String>
        
        if(notification.name == "deviceIDChanged") {
            deviceID = data["id"]!
        } else if(notification.name == "userIDChanged") {
            userID = data["id"]!
        } else if(notification.name == "emailChanged") {
            email = data["email"]!
        } else if(notification.name == "phoneNumberChanged") {
            phone = data["phone"]!
        }
        
        saveUserData()
    }
    
    func accountIsCreated() -> Bool {
        
        var isCreated : Bool = false
        
        if let checkUserID = userID {
            if let checkDeviceID = deviceID {
                if(userID! != "" && deviceID! != "") {
                    isCreated = true
                }
            }
        }
        
        return isCreated
    }
    
    func documentDirectoryPath() -> NSURL {
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as! [NSURL]
        return urls[0]
    }
    
    func loadUserData() {
        let path = documentDirectoryPath().URLByAppendingPathComponent("/UserData.plist")
        if(fileManager.fileExistsAtPath(path.path!)) {
            loadFromAppDirectory()
        }
    }
    
    func loadFromAppDirectory() {
        
        let path = documentDirectoryPath().URLByAppendingPathComponent("/UserData.plist")
        let dataEntry = NSDictionary(contentsOfFile: path.path!) as! Dictionary<String, String>
        
        if let checkUserIDEntry = dataEntry["userID"] {
            userID = dataEntry["userID"]
        }
        
        if let checkDeviceIDEntry = dataEntry["deviceID"] {
            deviceID = dataEntry["deviceID"]
        }
        
    }
    
    func saveUserData() {
        
        let path = documentDirectoryPath().URLByAppendingPathComponent("/UserData.plist")
        
        var dictionaryToWrite = buildDataToWrite()
        
        (dictionaryToWrite as NSDictionary).writeToURL(path, atomically: true)
    }
    
    func buildCustomer() -> Dictionary<String, String> {
        var returnDictionary = Dictionary<String, String>()
        
        if let checkID = userID {
            returnDictionary["userID"] = userID!
        } else {
            returnDictionary["Error"] = "No user data"
        }
        
        if let checkPhone = phone {
            returnDictionary["phone"] = phone!
        } else {
            returnDictionary["phone"] = "No phone data"
        }
        
        if let checkEmail = email {
            returnDictionary["email"] = email!
        } else {
            returnDictionary["email"] = "No email data"
        }
        
        return returnDictionary
    }
    
    func updateCustomerInfo(phone: String?, email: String?, userID : String?) {
        
        if let checkID = userID {
            self.userID = userID!
        }
        
        if let checkPhone = phone {
            self.phone = phone!
        }
        
        if let checkEmail = email {
            self.email = email!
        }
    }
    
    func saveImageToFile(image : UIImage, name : String) {
        
        let fileExtension = "/\(name)"
        let path = documentDirectoryPath().URLByAppendingPathComponent(fileExtension)
        
        let imageData = UIImagePNGRepresentation(image)
        fileManager.createFileAtPath(path.path!, contents: imageData, attributes: nil)
        
    }
    
    func buildDataToWrite() -> Dictionary<String, String> {
        
        var dictionaryToWrite = [String:String]()
        
        if let checkUserID = userID {
            dictionaryToWrite["userID"] = userID!
        }
        
        if let checkDeviceID = deviceID {
            dictionaryToWrite["deviceID"] = deviceID!
        }
        
        if let checkPhone = phone {
            dictionaryToWrite["phone"] = phone!
        }
        
        if let checkEmail = email {
            dictionaryToWrite["email"] = email!
        }
        
        return dictionaryToWrite
    }
}