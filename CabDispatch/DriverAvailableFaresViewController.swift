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
    var startingAnnotations : [MKAnnotationView]?
    var destinationAnnotations: [MKAnnotationView]?
    var pinImage : UIImage?
    var originPinImage : UIImage?
    var destinationPinImage : UIImage?
    var fareCustomerIDs : Dictionary<String, String>?
    var selectedFareID : String?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingAnnotations = [MKAnnotationView]()
        destinationAnnotations = [MKAnnotationView]()
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
        mapView.delegate = self
        
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
            //println("Value: \(value)")
            if let fare = value as? Dictionary<String, AnyObject> {
                if let startingPoint = fare["Location"] as? Dictionary<String, AnyObject>, destination = fare["Destination"] as? Dictionary<String, AnyObject> {
                    //println("Origin: \(startingPoint)")
                    //println("Destination: \(destination)")
                    //println("Fare: \(fare)")
                    //println("Value: \(value)")
                    let user = value["UserID"] as! String
                    fareCustomerIDs![key] = user
                    
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
                    startingAnnotation.title = "Origin\(key)"
                    mapView.addAnnotation(startingAnnotation)
                    
                    
                    let destinationCoords = CLLocationCoordinate2DMake(destinationLat, destinationLong)
                    let destinationAnnotation = MKPointAnnotation()
                    destinationAnnotation.coordinate = destinationCoords
                    destinationAnnotation.title = "Destination\(key)"
                    mapView.addAnnotation(destinationAnnotation)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let startIndex = view.reuseIdentifier.startIndex
        if(view.reuseIdentifier[startIndex] == "O") {
            //println("Origin: \(view.reuseIdentifier)")
            view.image = originPinImage!
            let index = advance(startIndex, 6)
            let range = index..<view.reuseIdentifier.endIndex
            let id = view.reuseIdentifier.substringWithRange(range)
            selectedFareID = id
            let destinationReuseID = "Destination\(id)"
            for ann in destinationAnnotations! {
                if(ann.reuseIdentifier == destinationReuseID) {
                    println("Destination: \(ann.reuseIdentifier)")
                    ann.image = pinImage!
                } else {
                    ann.image = destinationPinImage!
                }
            }
        } else {
            view.image = destinationPinImage!
            //println("Destination: \(view.reuseIdentifier)")
            let index = advance(startIndex, 11)
            let range = index..<view.reuseIdentifier.endIndex
            let id = view.reuseIdentifier.substringWithRange(range)
            selectedFareID = id
            let originReuseID = "Origin\(id)"
            for ann in startingAnnotations! {
                if(ann.reuseIdentifier == originReuseID) {
                    println("Origin: \(ann.reuseIdentifier)")
                    ann.image = pinImage!
                } else {
                    ann.image = originPinImage!
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if(!(annotation is MKPointAnnotation)) {
            return nil
        }
        
        var reuseID = annotation.title!
        
        var ann = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        if(ann == nil && reuseID[reuseID.startIndex] == "O") {
            var pinAnn = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinImage = pinAnn.image
            pinAnn.pinColor = MKPinAnnotationColor.Green
            originPinImage = pinAnn.image
            ann = pinAnn
            startingAnnotations?.append(ann)
        } else {
            var pinAnn = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinAnn.pinColor = MKPinAnnotationColor.Purple
            destinationPinImage = pinAnn.image
            ann = pinAnn
            destinationAnnotations?.append(ann)
        }
        
        return ann
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
        println("Accept")
        /*if let driver = dataManager.userID {
            println("\(driver)")
        }
        if let fareID = selectedFareID {
            println("\(fareID)")
        }*/
        if let driver = dataManager.userID, fareID = selectedFareID {
            let controller = AppConstants.ServerControllers.Driver
            let action = AppConstants.ControllerActions.AcceptFare
            let actions = [action.0, action.1]
            var params = Dictionary<String, String>()
            params["driverID"] = driver
            params["customerID"] = fareCustomerIDs![fareID]
            var response = serverManager.sendRequest(controller, action: actions, params: params, requestBody: nil)
            println("Response: \(response)")
        }
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
