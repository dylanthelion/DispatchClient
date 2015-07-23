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
    let serverManager = DriverRequests()
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
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func buildFareList() {
        if dataManager.accountIsCreated() {
            let fares = getFares()
            
            if(fares.isEmpty == true) {
                buildNoFaresLabel()
            } else if let message = fares["Message"] as? String {
                buildErrorLabel(message)
            } else {
                fareLabels = [UILabel]()
                buildFareLabels(fares)
            }
        } else {
            buildNoAccountLabel()
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
        
        let dictionaryToReturn = serverManager.getAssignedFares(dataManager.userID!, orderedBy: "location")
        
        return dictionaryToReturn as Dictionary<String, AnyObject>
    }
    
    func buildNoFaresLabel() {
        
        let label = UILabel(frame: CGRectMake(0, 75, width, labelHeight))
        label.text = "No fares currently"
        view.addSubview(label)
    }
    
    func buildErrorLabel(message : String) {
        let label = UILabel(frame: CGRectMake(0, 75, width, labelHeight))
        label.text = message
        label.backgroundColor = UIColor.yellowColor()
        view.addSubview(label)
    }
    
    func buildNoAccountLabel() {
        let label = UILabel(frame: CGRectMake(0, 75, width, labelHeight))
        label.text = "No user account created"
        view.addSubview(label)
    }
    
    func buildFareLabels(fares : Dictionary<String, AnyObject>) {
        var labelCount : CGFloat = 0
        for(key, value) in fares {
            var yCoord : CGFloat = labelHeight * labelCount
            yCoord = yCoord + 75
            
            let label = UILabel(frame: CGRectMake(0, yCoord, width, labelHeight))
            var labelText : String = "\(key)"
            if let checkValue = value as? Dictionary<String, AnyObject> {
                labelText = buildStringFromDictionary(checkValue, root: labelText)
            } else {
                labelText += "Error"
            }
            
            
            label.text = labelText
            
            view.addSubview(label)
            fareLabels?.append(label)
            labelCount = labelCount + 1
        }
    }

}
