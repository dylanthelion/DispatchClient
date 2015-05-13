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
    
    var locationManager = GlobalLocationManager.appLocationManager
    var dataManager = UserData.getData
    var serverManager = ServerManager.defaultManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startLocating(self)
        
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
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.isLocating = true
        let location = locationManager.location
        dataManager.currentLocation = location
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        var email : String? = nil
        var phone : String? = nil
        
        var customerInfo = Dictionary<String, String>()
        
        if(phoneTextField.text != "") {
            phone = phoneTextField.text
        }
        
        if(emailTextField.text != "") {
            email = emailTextField.text
        }
        
        if(dataManager.accountIsCreated()) {
            println("Patch customer")
            serverManager.updateCustomer(phone, email: email, location: locationManager.location)
        } else {
            var response = serverManager.createCustomer(phone, email: email, location: locationManager.location)
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier! == "showCustomerInfo") {
            
            var customerInfo : Dictionary<String, String> = dataManager.buildCustomer()
            
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
        }
    }

}
