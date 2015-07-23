//
//  ServerManager.swift
//  CabDispatch
//
//  Created by Dylan on 5/2/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let globalServerManager = ServerManager()

class ServerManager {
    
    var deviceID : String?
    var jsonManager = APIObjectBuilder.defaultBuilder
    
    
    class var defaultManager : ServerManager {
        return globalServerManager
    }
    
    init() {
        setupNotifications()
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: "deviceIDChanged", object: nil)
    }
    
    func handleNotification(notification : NSNotification) {
        
        var data = notification.userInfo as! Dictionary<String, String>
        
        if(notification.name == "deviceIDChanged") {
            deviceID = data["id"]!
        }
    }
    
    func sendRequest(controller : String, action : [AnyObject], params : Dictionary<String, String>?, requestBody : Dictionary<String, AnyObject>?) -> NSDictionary {
        
        let controllerAction = action[1] as! String
        let requestType = action[0] as! String
        var returnObject : NSDictionary? = nil
        var isDone : Bool = false
        
        var url : NSMutableURLRequest = NSMutableURLRequest(URL: APIFuncs.buildURL(controller, action: controllerAction, params: params))
        url.HTTPMethod = requestType
        
        var sentURL = APIFuncs.buildURL(controller, action: controllerAction, params: params)
        
        // check to make sure request is built properly; many of the requests sent with an already-created account will only return a json-encoded error message
        
        print("URL: \(sentURL)")
        
        if let checkForBody = requestBody {
            if(action.count > 2) {
                var error : NSError?
                do {
                    url.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBody!, options: [])
                } catch var error1 as NSError {
                    error = error1
                    url.HTTPBody = nil
                }
            }
        }
        
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(url, completionHandler: {data, response, error -> Void in
            
            //println("\(response)")
            //println("\(data)")
            
            var err : NSError?
            
            if let responseObject  = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? NSDictionary {
                
                returnObject = responseObject
                print("Dictionary get")
                
            } else if let responseObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? NSArray {
                
                print("Array get")
                returnObject = self.jsonManager.jsonArrayToDictionary(responseObject)
                
            } else {
                
                returnObject = self.jsonManager.jsonMessageStringToDictionary(data)
                print("Message get")
            }
            
            
            if(err != nil) {
                returnObject = NSMutableDictionary()
                returnObject!.setValue("You done messed up", forKey: "Error")
                print("Error get: \(err?.localizedDescription)")
            }
        })
        
        task.resume()
        
        // Let's set up an asynchronous call, if and when we do this for realz. This is dumb.
        while (returnObject == nil) {
            
        }
        
        return returnObject!
    }
    
    
}