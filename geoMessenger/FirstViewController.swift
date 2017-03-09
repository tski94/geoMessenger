//
//  FirstViewController.swift
//  geoMessenger
//
//  Created by Ivor D. Addo on 3/6/17.
//  Copyright © 2017 Marquette University. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class FirstViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var messageNodeRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        
        //Set Initial Location
        let initialLocation = CLLocation(latitude: 43.038611, longitude: -87.928759)
        centerMapOnLocation(location: initialLocation)
        checkLocationAuthorizationStatus()
        
        //Create Firebase DB reference
        messageNodeRef = FIRDatabase.database().reference().child("messages")
        
        //use observe handler to poll for realtime updates
        let pinMessageId = "msg-1"
        var pinMessage: Message?
        messageNodeRef.child(pinMessageId).observe(.value, with: { (snapshot: FIRDataSnapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                //if pin already exists, remove it first
                if pinMessage != nil {
                    self.mapView.removeAnnotation(pinMessage!)
                }
                let pinLat = dictionary["latitude"] as! Double
                let pinLong = dictionary["longitude"] as! Double
                let messageDisabled = dictionary["isDisabled"] as! Bool
                
                let message = Message(title: (dictionary["title"] as? String)!,
                                      locationName: (dictionary["locationName"] as? String)!,
                                      username: (dictionary["username"] as? String)!,
                                      coordinate: CLLocationCoordinate2D(latitude: pinLat, longitude: pinLong),
                                      isDisabled: messageDisabled)
                
                pinMessage = message
                
                if !message.isDisabled {
                    self.mapView.addAnnotation(message)
                }
            }
        })
    
        
        //Show messages on the map
        let message = Message(title: "The bucks are legit!",
        locationName: "Bradley Center",
        username: "John Smith",
        coordinate: CLLocationCoordinate2D(latitude: 43.043914, longitude: -87.917262),
        isDisabled: false)
        
        mapView.addAnnotation(message)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
}

