//
//  CustomerRequestFareViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CustomerRequestFareViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var locationManager = GlobalLocationManager.appLocationManager
    var geocoder : CLGeocoder?
    var destination : CLLocation?
    
    let dataManager = UserData.getData
    let serverManager = ServerManager.defaultManager
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var currentAddressTextField: UITextField!
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocating()
        buildMap()
        
        currentAddressTextField.delegate = self
        destinationTextField.delegate = self
        
        geocoder = CLGeocoder()
        
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
    }
    
    @IBAction func requestFare(sender: AnyObject) {
        let destinationAddress = destinationTextField.text
        
        if(dataManager.accountIsCreated() == false) {
            errorLabel.text = "Please create an account first"
            return
        }
        
        let geocodedDestination: Void? = geocoder?.geocodeAddressString(destinationAddress, inRegion: nil, completionHandler: {(placemarks : [AnyObject]!, error: NSError!) -> Void in
            if(error != nil) {
                println("Error: \(error)")
            }
            
            else if let placemark = placemarks?[0] as? CLPlacemark {
                self.destination = placemark.location
                
                if(self.destination?.distanceFromLocation(self.locationManager.location) < 100000.0) {
                    self.sendFareRequest()
                } else {
                    self.errorLabel.text = "Invalid location"
                }
            }
            
        })
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendFareRequest() {
        
        var location : CLLocation
        
        if let checkLocation = dataManager.currentLocation {
            location = checkLocation
        } else {
            location = locationManager.location
        }
        
        serverManager.requestFare(location, destination: destination!, phone: dataManager.phone, email: dataManager.email, userID: dataManager.userID)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.isLocating = true
        let location = locationManager.location
        dataManager.currentLocation = location
    }
}
