//
//  AvailableFaresMapDelegate.swift
//  CabDispatch
//
//  Created by Dylan on 5/14/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class AvailableFaresMapDelegate : NSObject, MKMapViewDelegate {
    
    var startingAnnotations : [MKAnnotationView]?
    var destinationAnnotations: [MKAnnotationView]?
    var pinImage : UIImage?
    var originPinImage : UIImage?
    var destinationPinImage : UIImage?
    var selectedFareID : String?
    
    override init() {
        println("Init delegate")
        startingAnnotations = [MKAnnotationView]()
        destinationAnnotations = [MKAnnotationView]()
        super.init()
        
        loadPinImages()
    }
    
    func loadPinImages() {
        pinImage = UIImage(named: "RedMapPin")
        originPinImage = UIImage(named: "GreenMapPin")
        destinationPinImage = UIImage(named: "PurpleMapPin")
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        let startIndex = view.reuseIdentifier.startIndex
        
        if(view.reuseIdentifier[startIndex] == "O") {
            let id = view.reuseIdentifier.getNumericPostscript()!
            selectedFareID = "\(id)"
            let destinationReuseID = "Destination\(id)"
            for ann in destinationAnnotations! {
                if(ann.reuseIdentifier == destinationReuseID) {
                    ann.image = pinImage!
                } else {
                    ann.image = destinationPinImage!
                }
            }
        } else {
            view.image = destinationPinImage!
            let id = view.reuseIdentifier.getNumericPostscript()
            selectedFareID = "\(id!)"
            let originReuseID = "Origin\(id)"
            for ann in startingAnnotations! {
                if(ann.reuseIdentifier == originReuseID) {
                    ann.image = pinImage!
                } else {
                    ann.image = originPinImage!
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        println("View for annotation")
        
        if(!(annotation is MKPointAnnotation)) {
            return nil
        }
        
        var reuseID = annotation.title!
        
        var ann = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        if(ann == nil && reuseID[reuseID.startIndex] == "O") {
            ann = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            ann.image = originPinImage!
            startingAnnotations?.append(ann)
        } else {
            ann = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            ann.image = destinationPinImage!
            destinationAnnotations?.append(ann)
        }
        
        return ann
    }
    
    
}