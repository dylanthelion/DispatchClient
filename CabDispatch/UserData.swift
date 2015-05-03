//
//  UserData.swift
//  CabDispatch
//
//  Created by Dylan on 5/2/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation

private let globalUserData = UserData()

class UserData {
    
    var userID : String?
    var deviceID : String?
    var phone : String?
    var email : String?
    let fileManager = NSFileManager.defaultManager()
    
    class var getData : UserData {
        return globalUserData
    }
    
    init() {
        loadUserData()
    }
    
    func setUserID(userID : String) {
        self.userID = userID
        if(accountIsCreated() == true) {
            saveUserData()
        }
    }
    
    func setDeviceID(deviceID : String) {
        self.deviceID = deviceID
        if(accountIsCreated() == true) {
            saveUserData()
        }
    }
    
    func setPhone(phone : String) {
        self.phone = phone
        if(accountIsCreated() == true) {
            saveUserData()
        }
    }
    
    func setEmail(email : String) {
        self.email = email
        if(accountIsCreated() == true) {
            saveUserData()
        }
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
        let path = documentDirectoryPath().URLByAppendingPathComponent("UserData.plist")
        
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
        
        (dictionaryToWrite as NSDictionary).writeToURL(path, atomically: true)
    }
}