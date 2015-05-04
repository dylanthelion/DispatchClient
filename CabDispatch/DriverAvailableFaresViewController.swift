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

class DriverAvailableFaresViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager : CLLocationManager?
    let dataManager = UserData.getData
    let serverManager = ServerManager.defaultManager
    var startingAnnotations : [MKPointAnnotation]?
    var destinationAnnotations: [MKPointAnnotation]?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingAnnotations = [MKPointAnnotation]()
        destinationAnnotations = [MKPointAnnotation]()
        
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
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
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
        var allFares = getFares("location")
        //println("Fares: \(allFares)")
        
        for(key, value) in allFares {
            if let fare = value as? Dictionary<String, AnyObject> {
                if let startingPoint = fare["Location"] as? Dictionary<String, AnyObject>, destination = fare["Destination"] as? Dictionary<String, AnyObject> {
                    var startingLatSign = startingPoint["Latitude_sign"] as! String
                    var startingLongSign = startingPoint["Longitude_sign"] as! String
                    var startingLat = startingPoint["Latitude"] as! Double
                    var startingLong = startingPoint["Longitude"] as! Double
                    
                    var destinationLatSign = destination["Latitude_sign"] as! String
                    var destinationLongSign = destination["Longitude_sign"] as! String
                    var destinationLat = destination["Latitude"] as! Double
                    var destinationLong = destination["Longitude"] as! Double
                    
                    if(startingLatSign == "-") {
                        startingLat *= -1
                    }
                    
                    if(startingLongSign == "-") {
                        startingLong *= -1
                    }
                    
                    if(destinationLatSign == "-") {
                        destinationLat *= -1
                    }
                    
                    if(destinationLongSign == "-") {
                        destinationLong *= -1
                    }
                    
                    let startingCoords = CLLocationCoordinate2DMake(startingLat, startingLong)
                    let startingAnnotation = MKPointAnnotation()
                    startingAnnotation.coordinate = startingCoords
                    mapView.addAnnotation(startingAnnotation)
                    startingAnnotations?.append(startingAnnotation)
                    
                    
                    let destinationCoords = CLLocationCoordinate2DMake(destinationLat, destinationLong)
                    let destinationAnnotation = MKPointAnnotation()
                    destinationAnnotation.coordinate = destinationCoords
                    mapView.addAnnotation(destinationAnnotation)
                    destinationAnnotations?.append(destinationAnnotation)
                }
            }
        }
    }
    
    func getFares(filter : String?) -> Dictionary<String, AnyObject> {
        let controller = AppConstants.ServerControllers.FareRequest
        let action = AppConstants.ControllerActions.AllFares
        let actions = [action.0, action.1]
        
        var dictionaryToReturn = serverManager.sendRequest(controller, action: actions, params: nil, requestBody: nil)
        
        return dictionaryToReturn as! Dictionary<String, AnyObject>
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
