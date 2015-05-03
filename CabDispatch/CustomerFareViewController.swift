//
//  CustomerFareViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CustomerFareViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    var locationManager : CLLocationManager?
    let dataManager = UserData.getData
    let serverManager = ServerManager.defaultManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        startLocating()
        buildMap()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLocating() {
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func buildMap() {
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let myLocation = locationManager?.location
        var myCoords : CLLocationCoordinate2D
        if let checkLocation = dataManager.currentLocation {
            myCoords = checkLocation.coordinate
        } else {
            myCoords = myLocation!.coordinate
        }
        let region = MKCoordinateRegionMake(myCoords, span)
        
        mapView.setRegion(region, animated: true)
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        
        buildAnnotations()
    }
    
    func buildAnnotations() {
        var drivers = getDrivers()
        
        for(key, value) in drivers {
            if let driver = value as? Dictionary<String, AnyObject> {
                println("Driver: \(driver)")
                
                if let driverLocation = driver["Location"] as? Dictionary<String, AnyObject> {
                    var latSign = driverLocation["Latitude_sign"] as! String
                    var longSign = driverLocation["Longitude_sign"] as! String
                    var lat = driverLocation["Latitude"] as!Double
                    var long = driverLocation["Longitude"] as! Double
                    
                    if(latSign == "-") {
                        lat *= -1
                    }
                    
                    if (longSign == "-") {
                        long *= -1
                    }
                    
                    let driverCoords = CLLocationCoordinate2DMake(lat, long)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = driverCoords
                    mapView.addAnnotation(annotation)
                }
            }
        }
        
    }
    
    func getDrivers() -> Dictionary<String, AnyObject> {
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.AllEmptyDrivers
        let actions = [action.0, action.1]
        var params : Dictionary<String, String> = Dictionary<String, String>()
        
        if let loc = dataManager.currentLocation {
            params["Latitude"] = "\(loc.coordinate.latitude)"
            params["Longitude"] = "\(loc.coordinate.longitude)"
            
            if(loc.coordinate.latitude >= 0) {
                params["Latitude_sign"] = "%2B"
            } else {
                params["Latitude_sign"] = "%2D"
            }
            
            if(loc.coordinate.longitude >= 0) {
                params["Longitude_sign"] = "%2D"
            } else {
                params["Longitude_sign"] = "%2B"
            }
        }
        
        else {
            let loc = locationManager?.location
            params["Latitude"] = "\(loc!.coordinate.latitude)"
            params["Longitude"] = "\(loc!.coordinate.longitude)"
            
            if(loc!.coordinate.latitude >= 0) {
                params["Latitude_sign"] = "%2B"
            } else {
                params["Latitude_sign"] = "%2D"
            }
            
            if(loc!.coordinate.longitude >= 0) {
                params["Longitude_sign"] = "%2D"
            } else {
                params["Longitude_sign"] = "%2B"
            }
        }
        var dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    @IBAction func signup(sender: AnyObject) {
        var response = submitUserData()
        println("Response: \(response)")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
