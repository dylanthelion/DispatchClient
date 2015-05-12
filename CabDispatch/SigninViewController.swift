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
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if(identifier! == "driverSignin") {
            
            if(checkPassword()) {
                return true
            }
            
            badPasswordAlert()
            return false
        }
        
        return true
    }
    
    func badPasswordAlert() {
        var alert = UIAlertController(title: "Driver must enter password", message: "Try 'password'", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkPassword() -> Bool {
        if(passwordTextField.text == "password") {
            return true
        }
        
        return false
    }

}
