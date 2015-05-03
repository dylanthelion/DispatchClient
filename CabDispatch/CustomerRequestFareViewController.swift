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
    
    var locationManager : CLLocationManager?
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
                
                if(self.destination?.distanceFromLocation(self.locationManager?.location) < 100000.0) {
                    var response = self.sendFareRequest()
                    println("Response: \(response)")
                } else {
                    self.errorLabel.text = "Invalid location"
                }
            }
            
        })
    }
    
    func sendFareRequest() -> Dictionary<String, AnyObject> {
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.RequestFare
        let actions = [action.0, action.1, action.2]
        
        var location : CLLocation
        
        if let checkLocation = dataManager.currentLocation {
            location = checkLocation
        } else {
            location = locationManager!.location
        }
        
        var phone : String? = nil
        var email : String? = nil
        
        if let checkPhone = dataManager.phone {
            phone = dataManager.phone!
        }
        
        if let checkEmail = dataManager.email {
            email = dataManager.email!
        }
        
        var dictionaryToReturn : Dictionary<String, AnyObject> = serverManager.sendRequest(controller, action: actions as [AnyObject], params: nil, requestBody: serverManager.buildFareRequestJSON(location, destination: destination!, customerID: dataManager.userID!, phone: phone, email: email)) as! Dictionary<String, AnyObject>
        
        return dictionaryToReturn
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
