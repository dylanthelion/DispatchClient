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
    
    let locationManager = GlobalLocationManager.appLocationManager
    let dataManager = UserData.getData
    let serverManager = ServerManager.defaultManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.delegate = self
        emailTextField.delegate = self
        
        startLocating()
        buildMap()
        
        buildLogoutButton()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLocating() {
        locationManager.startLocating(self)
    }
    
    func buildMap() {
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let myLocation = locationManager.location
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
                //println("Driver: \(driver)")
                
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
        
        if(dataManager.currentLocation == nil) {
            dataManager.setCurrentLocation(locationManager.location)
        }
        
        params = dataManager.buildLocationParams()
        
        var dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.isLocating = true
        let location = locationManager.location
        dataManager.setCurrentLocation(location!)
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signup(sender: AnyObject) {
        var email : String? = nil
        var phone : String? = nil
        
        var customerInfo = Dictionary<String, String>()
        
        if(phoneTextField.text != "") {
            phone = phoneTextField.text
        }
        
        if(emailTextField.text != "") {
            email = emailTextField.text
        }
        
        dataManager.submitCustomer(phone, email: email)
    }

}
 