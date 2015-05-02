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

class CustomerRequestFareViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager?
    var geocoder : CLGeocoder?
    var destination : CLLocation?
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var currentAddressTextField: UITextField!
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocating()
        buildMap()
        
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
        let myCoords = myLocation?.coordinate
        
        let region = MKCoordinateRegionMake(myCoords!, span)
        
        mapView.setRegion(region, animated: true)
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        
    }
    
    @IBAction func requestFare(sender: AnyObject) {
        let destinationAddress = destinationTextField.text
        
        let geocodedDestination: Void? = geocoder?.geocodeAddressString(destinationAddress, inRegion: nil, completionHandler: {(placemarks : [AnyObject]!, error: NSError!) -> Void in
            if(error != nil) {
                println("Error: \(error)")
            }
            
            else if let placemark = placemarks?[0] as? CLPlacemark {
                self.destination = placemark.location
                
                if(self.destination?.distanceFromLocation(self.locationManager?.location) < 100.0) {
                    
                } else {
                    self.errorLabel.text = "Invalid location"
                }
            }
            
            
        })
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
