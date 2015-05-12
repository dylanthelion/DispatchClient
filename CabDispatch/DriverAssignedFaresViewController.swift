//
//  DriverAssignedFaresViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit

class DriverAssignedFaresViewController: UIViewController {
    
    let dataManager = UserData.getData
    let serverManager = ServerManager.defaultManager
    let width = UIScreen.mainScreen().bounds.width
    let height = UIScreen.mainScreen().bounds.height
    var labelHeight : CGFloat = 0.0
    var fareLabels : [UILabel]?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeight = 50
        buildFareList()
        
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
    
    func buildFareList() {
        if dataManager.accountIsCreated() {
            let fares = getFares()
            if(fares.isEmpty == true) {
                println("No fares")
                let label = UILabel(frame: CGRectMake(0, 75, width, labelHeight))
                label.text = "No fares currently"
                view.addSubview(label)
            } else if let message = fares["Message"] as? String {
                println("Message: \(message)")
                let label = UILabel(frame: CGRectMake(0, 75, width, labelHeight))
                label.text = message
                label.backgroundColor = UIColor.yellowColor()
                view.addSubview(label)
            } else {
                println("Haz fares")
                fareLabels = [UILabel]()
                //println("Fares: \(fares)")
                var labelCount : CGFloat = 0
                for(key, value) in fares {
                    var yCoord : CGFloat = labelHeight * labelCount
                    yCoord = yCoord + 75
                    
                    let label = UILabel(frame: CGRectMake(0, yCoord, width, labelHeight))
                    var labelText : String = "\(key)"
                    if let checkValue = value as? Dictionary<String, AnyObject> {
                        labelText = buildStringFromDictionary(checkValue, labelText)
                    } else {
                        labelText += "Error"
                    }
                    
                    
                    label.text = labelText
                    
                    view.addSubview(label)
                    fareLabels?.append(label)
                    labelCount = labelCount + 1
                }
            }
        } else {
            println("No user account")
            let label = UILabel(frame: CGRectMake(0, 75, width, labelHeight))
            label.text = "No user account created"
            view.addSubview(label)
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let checkLabels = fareLabels {
            var labelCount : CGFloat = 0
            for label in fareLabels! {
                var yCoord : CGFloat = labelCount * labelHeight
                yCoord = yCoord + 75
                
                label.frame = CGRectMake(0, yCoord, height, labelHeight)
                labelCount += 1
            }
        }
    }
    
    func getFares() -> Dictionary<String, AnyObject> {
        let controller = AppConstants.ServerControllers.Driver
        let action = AppConstants.ControllerActions.GetCustomerLocations
        let actions = [action.0, action.1]
        
        var params = Dictionary<String, String>()
        
        params["driverID"] = dataManager.userID!
        
        params["orderedBy"] = "location"
        
        var dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
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
