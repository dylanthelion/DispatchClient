//
//  CustomerRequests.swift
//  CabDispatch
//
//  Created by Dylan on 5/15/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

class CustomerRequests {
    
    let serverManager = ServerManager.defaultManager
    let notificationManager = NotificationManager.defaultManager
    let jsonManager = APIObjectBuilder.defaultBuilder
    var deviceID : String?
    
    init() {
        setupNotifications()
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: "deviceIDChanged", object: nil)
    }
    
    func handleNotification(notification : NSNotification) {
        
        var data = notification.userInfo as! Dictionary<String, String>
        
        if(notification.name == "deviceIDChanged") {
            deviceID = data["id"]!
        }
    }
    
    func createCustomer(phone : String?, email : String?, location : CLLocation) -> Dictionary<String, AnyObject> {
        
        let requestInfo = AppConstants.ControllerActions.CreateCustomer
        let actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        
        let customerObject = jsonManager.buildCustomerJSON(location, phone: phone, email: email, deviceID: deviceID)
        let response = serverManager.sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject) as! NSMutableDictionary
        
        
        if let unwrapDictionary = response["Driver0"] as? Dictionary<String, AnyObject> {
            
            if let checkForDictionary = unwrapDictionary["UserID"] as? Int {
                let id = "\(checkForDictionary)"
                notificationManager.postAccountUpdateNotifications(phone, email: email, userID: id, deviceID: nil)
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
    
    func patchCustomer(phone: String?, email: String?, location: CLLocation) {
        
        let requestInfo = AppConstants.ControllerActions.PatchCustomer
        let actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        
        let customerObject = jsonManager.buildCustomerJSON(location, phone: phone, email: email, deviceID: deviceID)
        var response = serverManager.sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject) as! NSMutableDictionary
        
    notificationManager.postAccountUpdateNotifications(phone, email: email, userID: nil, deviceID: nil)
        // check for 200?
    }
    
    func getNearbyDrivers(location: CLLocation) -> Dictionary<String, AnyObject> {
        
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.AllEmptyDrivers
        let actions = [action.0, action.1]
        let params : Dictionary<String, String> = APIFuncs.buildLocationParams(location)
        
        let dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
    
    func requestFare(location: CLLocation, destination : CLLocation, phone : String?, email : String?, userID : String?) {
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.RequestFare
        let actions = [action.0, action.1, action.2]
        
        
        var dictionaryToReturn : Dictionary<String, AnyObject> = serverManager.sendRequest(controller, action: actions as [AnyObject], params: nil, requestBody: jsonManager.buildFareRequestJSON(location, destination: destination, customerID: userID, phone: phone, email: email, deviceID: deviceID)) as! Dictionary<String, AnyObject>
    }
}
