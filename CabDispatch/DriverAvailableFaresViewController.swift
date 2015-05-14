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
    
    var locationManager = GlobalLocationManager.appLocationManager
    let dataManager = UserData.getData
    let serverManager = ServerManager.defaultManager
    let mapDelegate = AvailableFaresMapDelegate()
    var fareCustomerIDs : Dictionary<String, String>?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fareCustomerIDs = Dictionary<String, String>()
        
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
    
    func buildLogoutButton() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func logout() {
        self.parentViewController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func buildMap() {
        mapView.delegate = mapDelegate
        
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
        
        var allFares = serverManager.allFares()
        //println("Fares: \(allFares)")
        
        for(key, value) in allFares {
            //println("Value: \(value)")
            if let fare = value as? Dictionary<String, AnyObject> {
                
                if let startingPoint = fare["Location"] as? Dictionary<String, AnyObject>, destination = fare["Destination"] as? Dictionary<String, AnyObject> {
                    
                    let user = value["UserID"] as! String
                    fareCustomerIDs![key] = user
                    
                    let startingCoords = buildCoordsFromLocationDictionary(startingPoint)
                    let startingAnnotation = MKPointAnnotation()
                    startingAnnotation.coordinate = startingCoords
                    startingAnnotation.title = "Origin\(key)"
                    mapView.addAnnotation(startingAnnotation)
                    
                    
                    let destinationCoords = buildCoordsFromLocationDictionary(destination)
                    let destinationAnnotation = MKPointAnnotation()
                    destinationAnnotation.coordinate = destinationCoords
                    destinationAnnotation.title = "Destination\(key)"
                    mapView.addAnnotation(destinationAnnotation)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.isLocating = true
        let location = locationManager.location
        dataManager.currentLocation = location
    }
    
    @IBAction func filterFares(sender: AnyObject) {
    }

    @IBAction func acceptChosenFare(sender: AnyObject) {
        if let driver = dataManager.userID, fareID = mapDelegate.selectedFareID {
            serverManager.acceptFare(fareCustomerIDs![fareID]!, driverID: driver)
        }
    }
    
    
    @IBAction func clearCurrentFares(sender: AnyObject) {
    }

}
