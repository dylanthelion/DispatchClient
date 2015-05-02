//
//  SigninViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    
    let userDataManager = UserData.getData
    var passwordIsValid : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self

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
    

    @IBAction func signinCustomer(sender: AnyObject) {
        let deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
        println("Device: \(deviceID)")
    }
    
    @IBAction func signinDriver(sender: AnyObject) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if(identifier! == "driverSignin") {
            if(passwordTextField.text == "password") {
                passwordIsValid = true
            }
            
            if(passwordIsValid == false) {
                badPasswordAlert()
                return false
            }
        }
        
        return true
    }
    
    func badPasswordAlert() {
        var alert = UIAlertController(title: "Driver must enter password", message: "Try 'password'", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
