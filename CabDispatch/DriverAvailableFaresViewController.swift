//
//  DriverAvailableFaresViewController.swift
//  CabDispatch
//
//  Created by Dylan on 5/1/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DriverAvailableFaresViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocating()
        buildMap()
        addAnnotations()

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
    
    func addAnnotations() {
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    @IBAction func filterFares(sender: AnyObject) {
    }

    @IBAction func acceptChosenFare(sender: AnyObject) {
    }
    
    
    @IBAction func clearCurrentFares(sender: AnyObject) {
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
