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

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeight = 50
        buildFareList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                println("Fares: \(fares)")
                var labelCount : CGFloat = 0
                for(key, value) in fares {
                    var yCoord : CGFloat = labelHeight * labelCount
                    yCoord = yCoord + 75
                    
                    let label = UILabel(frame: CGRectMake(0, yCoord, width, labelHeight))
                    let labelText = "\(key) : \(value)"
                    
                    label.text = labelText
                    
                    view.addSubview(label)
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
