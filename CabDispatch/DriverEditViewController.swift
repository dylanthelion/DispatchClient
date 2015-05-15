//
//  DriverEditViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit
import CoreLocation

class DriverEditViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var locationManager = GlobalLocationManager.appLocationManager
    let dataManager = UserData.getData
    let serverManager = DriverRequests()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocating()
        
        buildLogoutButton()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLocating() {
        locationManager.startLocating(self)
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.isLocating = true
        let location = locationManager.location
        dataManager.currentLocation = location
    }
    

    @IBAction func createAccount(sender: AnyObject) {
        if(dataManager.accountIsCreated() == true) {
            println("Patch driver")
            serverManager.patchDriver(locationManager.location)
        } else {
            serverManager.createDriver(locationManager.location)
        }
    }
    
    func submitUserData() {
        /*var customerInfo = Dictionary<String, String>()
        
        if(dataManager.accountIsCreated() == true) {
            let requestInfo = AppConstants.ControllerActions.CreateDriver
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            var location = locationManager.location
            var driverObject = serverManager.buildDriverJSON(location)
            var response = serverManager.sendRequest(AppConstants.ServerControllers.Driver, action: actionArray, params: nil, requestBody: driverObject)
            customerInfo["userID"] = dataManager.userID!
        } else {
            serverManager.setDeviceID(UIDevice.currentDevice().identifierForVendor.UUIDString)
            let requestInfo = AppConstants.ControllerActions.CreateDriver
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            var location = locationManager.location
            var driverObject = serverManager.buildDriverJSON(location)
            var response = serverManager.sendRequest(AppConstants.ServerControllers.Driver, action: actionArray, params: nil, requestBody: driverObject)
            if let unwrapDictionary = response["Driver0"] as? Dictionary<String, AnyObject> {
            if let checkForDictionary = unwrapDictionary["UserID"] as? Int {
                dataManager.setDeviceID(UIDevice.currentDevice().identifierForVendor.UUIDString)
                dataManager.setUserID("\(checkForDictionary)")
                customerInfo["userID"] = "\(checkForDictionary)"
            } else {
                customerInfo["Error"] = "Submit failed"
            }
            }
        }
        
        return customerInfo*/
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if(segue.identifier! == "submitDriverInfo") {
            var customerInfo : Dictionary<String, String> = submitUserData()
            
            if let destination = segue.destinationViewController as? DriverInfoViewController {
                if(customerInfo["Error"] != nil) {
                    destination.labelData[1] = customerInfo["Error"]!
                } else {
                    destination.labelData[0] = customerInfo["userID"]!
                }
            }
        } else if (segue.identifier! == "showDriverInfo") {
            var customerInfo : Dictionary<String, String> = submitUserData()
            
            if let destination = segue.destinationViewController as? DriverInfoViewController {
                if let checkUserID = dataManager.userID {
                    destination.labelData[0] = dataManager.userID!
                } else {
                    destination.labelData[0] = "No User ID"
                }
            }
        }*/
    }
    

}
