//
//  DriverRequests.swift
//  CabDispatch
//
//  Created by Dylan on 5/15/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

class DriverRequests {
    
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
    
    func createDriver(location : CLLocation) -> Dictionary<String, AnyObject> {
        let requestInfo = AppConstants.ControllerActions.CreateDriver
        var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        var driverObject = jsonManager.buildDriverJSON(location, deviceID: deviceID)
        var response = serverManager.sendRequest(AppConstants.ServerControllers.Driver, action: actionArray, params: nil, requestBody: driverObject) as! NSMutableDictionary
        if let unwrapDictionary = response["Driver0"] as? Dictionary<String, AnyObject> {
            if let checkForDictionary = unwrapDictionary["UserID"] as? Int {
                
            notificationManager.postAccountUpdateNotifications(nil, email: nil, userID: "\(checkForDictionary)", deviceID: nil)
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
    
    func patchDriver(location : CLLocation) {
        let requestInfo = AppConstants.ControllerActions.PatchDriver
        var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
        var driverObject = jsonManager.buildDriverJSON(location, deviceID: deviceID)
        var response = serverManager.sendRequest(AppConstants.ServerControllers.Driver, action: actionArray, params: nil, requestBody: driverObject)
    }
    
    func allFares() -> Dictionary<String, AnyObject> {
        
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.AllFares
        let actions = [action.0, action.1]
        
        var dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: nil, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
    
    func acceptFare(fareID : String, driverID : String) {
        
        let controller = AppConstants.ServerControllers.Driver
        let action = AppConstants.ControllerActions.AcceptFare
        let actions = [action.0, action.1]
        var params = Dictionary<String, String>()
        params["driverID"] = driverID
        params["customerID"] = fareID
        var response = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
    }
    
    func getAssignedFares(driverID : String, orderedBy : String) -> Dictionary<String, AnyObject> {
        
        let controller = AppConstants.ServerControllers.Driver
        let action = AppConstants.ControllerActions.GetCustomerLocations
        let actions = [action.0, action.1]
        
        var params = Dictionary<String, String>()
        
        params["driverID"] = driverID
        
        params["orderedBy"] = orderedBy
        
        var dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
}
