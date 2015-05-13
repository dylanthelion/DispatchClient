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

class UserData {
    
    var userID : String?
    var deviceID : String?
    var phone : String?
    var email : String?
    let fileManager = NSFileManager.defaultManager()
    let serverManager = ServerManager.defaultManager
    
    // used to preload maps
    var currentLocation : CLLocation?
    
    class var getData : UserData {
        return globalUserData
    }
    
    init() {
        println("Init user data")
        loadUserData()
        deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
    }
    
    func setCurrentLocation(location: CLLocation) {
        self.currentLocation = location
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
            println("Loaded user data")
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
        println("Save data")
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
    
    func submitCustomer(phone : String?, email : String?) {
        
        
        if(accountIsCreated()) {
            
            let requestInfo = AppConstants.ControllerActions.PatchCustomer
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            
            let customerObject = serverManager.buildCustomerJSON(self.currentLocation!, phone: phone, email: email)
            var response = serverManager.sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject) as! NSMutableDictionary
            
            updateCustomerInfo(phone, email: email, userID: nil)
            
            // check for 200?
            
            
            
        } else {
            
            let requestInfo = AppConstants.ControllerActions.CreateCustomer
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            
            var customerObject = serverManager.buildCustomerJSON(self.currentLocation!, phone: phone, email: email)
            var response = serverManager.sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject) as! NSMutableDictionary
            
            if let unwrapDictionary = response["Driver0"] as? Dictionary<String, AnyObject> {
                
                if let checkForDictionary = unwrapDictionary["UserID"] as? Int {
                    var id = "\(checkForDictionary)"
                    updateCustomerInfo(phone, email: email, userID: id)
                } else {
                    updateCustomerInfo(phone, email: email, userID: nil)
                }
            } else {
                response.setObject("SubmitFailed", forKey: "Error")
            }
            
            println("Response: \(response)")
        }
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
    
    func buildLocationParams() -> Dictionary<String, String> {
        
        var paramsToReturn = Dictionary<String, String>()
        
        if let location = currentLocation {
            paramsToReturn["Latitude"] = "\(currentLocation?.coordinate.latitude)"
            paramsToReturn["Longitude"] = "\(currentLocation?.coordinate.longitude)"
            
            if(currentLocation?.coordinate.latitude >= 0) {
                paramsToReturn["Latitude_sign"] = "%2B"
            } else {
                paramsToReturn["Latitude_sign"] = "%2D"
            }
            
            if(currentLocation?.coordinate.longitude >= 0) {
                paramsToReturn["Longitude_sign"] = "%2D"
            } else {
                paramsToReturn["Longitude_sign"] = "%2B"
            }
        }
        
        return paramsToReturn
    }
}