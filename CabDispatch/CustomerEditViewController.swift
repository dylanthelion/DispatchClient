//
//  CustomerEditViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit
import CoreLocation

class CustomerEditViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    var locationManager : CLLocationManager?
    var dataManager = UserData.getData
    var serverManager = ServerManager.defaultManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocating()
        
        phoneTextField.delegate = self
        emailTextField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func startLocating() {
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    }
    

    @IBAction func submit(sender: AnyObject) {
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier! == "showCustomerInfo") {
            var customerInfo : Dictionary<String, String> = submitUserData()
            
            if let destination = segue.destinationViewController as? CustomerInfoViewController {
                if customerInfo["Error"] != nil {
                    destination.invalidSubmit = true
                }
            }
        }
    }
    
    func submitUserData() -> Dictionary<String, String> {
        var email : String? = nil
        var phone : String? = nil
        
        var customerInfo = Dictionary<String, String>()
        
        if(phoneTextField.text != "") {
            phone = phoneTextField.text
            dataManager.phone = phoneTextField.text
        }
        
        if(emailTextField.text != "") {
            email = emailTextField.text
            dataManager.email = emailTextField.text
        }
        
        if(dataManager.accountIsCreated() == true) {
            let requestInfo = AppConstants.ControllerActions.PatchCustomer
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            var location = locationManager?.location
            var customerObject = serverManager.buildCustomerJSON(location!, phone: phone, email: email)
            var response = serverManager.sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject)
            customerInfo["userID"] = dataManager.userID!
        } else {
            serverManager.setDeviceID(UIDevice.currentDevice().identifierForVendor.UUIDString)
            let requestInfo = AppConstants.ControllerActions.CreateCustomer
            var actionArray : [AnyObject] = [requestInfo.0, requestInfo.1, requestInfo.2]
            var location = locationManager?.location
            var customerObject = serverManager.buildCustomerJSON(location!, phone: phone, email: email)
            var response = serverManager.sendRequest(AppConstants.ServerControllers.Customer, action: actionArray, params: nil, requestBody: customerObject)
            if let checkForDictionary = response["UserID"] as? Int {
                dataManager.setDeviceID(UIDevice.currentDevice().identifierForVendor.UUIDString)
                dataManager.setUserID("\(checkForDictionary)")
                customerInfo["userID"] = "\(checkForDictionary)"
            } else {
                customerInfo["Error"] = "Submit failed"
            }
        }
        
        return customerInfo
    }

}
