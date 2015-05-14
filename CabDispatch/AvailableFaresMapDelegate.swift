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
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("Did select")
        
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
        
        println("View for annotation")
        
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
    
    
}