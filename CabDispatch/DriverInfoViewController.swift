//
//  DriverInfoViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit

class DriverInfoViewController: UIViewController {

    @IBOutlet weak var userIDLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var labelData = ["", ""]
    var dataManager = UserData.getData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(dataManager.accountIsCreated()) {
            userIDLabel.text = dataManager.userID!
        } else {
            errorLabel.text = "No User Info"
        }
        
        
        buildLogoutButton()

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
