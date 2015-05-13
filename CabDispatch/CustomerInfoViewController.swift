//
//  CustomerInfoViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit

class CustomerInfoViewController: UIViewController {
    
    @IBOutlet weak var userIDLabel: UILabel!
    
    @IBOutlet weak var phoneOrErrorLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var dataManager = UserData.getData
    var labelData = ["", "", ""]
    var validSubmission = true
    

    override func viewDidLoad() {
        super.viewDidLoad()

        userIDLabel.text = labelData[0]
        phoneOrErrorLabel.text = labelData[1]
        emailLabel.text = labelData[2]
        
        buildLogoutButton()
        
        if(validSubmission == false) {
            phoneOrErrorLabel.textColor = UIColor.redColor()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
