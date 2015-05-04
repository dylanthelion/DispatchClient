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
        
        buildLogoutButton()

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
        let location = locationManager?.location
        dataManager.setCurrentLocation(location!)
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func submit(sender: AnyObject) {
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier! == "submitCustomerInfo") {
            var customerInfo : Dictionary<String, String> = submitUserData()
            
            if(customerInfo["phone"] == nil) {
                if let checkPhone = dataManager.phone {
                    customerInfo["phone"] = dataManager.phone!
                } else {
                    customerInfo["phone"] = "No user data"
                }
            }
            
            if(customerInfo["email"] == nil) {
                if let checkEmail = dataManager.email {
                    customerInfo["email"] = dataManager.email!
                } else {
                    customerInfo["email"] = "No user data"
                }
            }
            
            if let destination = segue.destinationViewController as? CustomerInfoViewController {
                if customerInfo["Error"] != nil {
                    destination.labelData[1] = customerInfo["Error"]!
                    destination.validSubmission = false
                    destination.labelData[0] = ""
                    destination.labelData[2] = ""
                } else {
                    var userID = customerInfo["userID"]!
                    var phone = customerInfo["phone"]!
                    var email = customerInfo["email"]!
                    destination.labelData[0] = "User ID : \(userID)"
                    destination.labelData[1] = "Phone: \(phone)"
                    destination.labelData[2] = "Email: \(email)"
                }
            }
        } else {
            if let destination = segue.destinationViewController as? CustomerInfoViewController {
                if let checkUserID = dataManager.userID {
                    destination.labelData[0] = "User ID: \(dataManager.userID!)"
                } else {
                    destination.labelData[0] = "No User ID"
                }
                
                if let checkPhone = dataManager.phone {
                    destination.labelData[1] = "Phone: \(dataManager.phone!)"
                } else {
                    destination.labelData[1] = "No phone sent"
                }
                
                if let checkEmail = dataManager.email {
                    destination.labelData[2] = "Email: \(dataManager.email!)"
                } else {
                    destination.labelData[2] = "No email sent"
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
            customerInfo["phone"] = phoneTextField.text
        }
        
        if(emailTextField.text != "") {
            email = emailTextField.text
            dataManager.email = emailTextField.text
            customerInfo["email"] = emailTextField.text
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
