//
//  LocationController.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import MapKit

class LocationController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    // Find an address from coordinates
    var geocoder = CLGeocoder()
    var coordinate: Coordinate? { // When coordinates are set the perform geocoding
        didSet {
            if let coordinate = coordinate {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let _ = error {
                        print("Unable to find address for location")
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first, let name = placemark.name, let locality = placemark.locality, let adminArea = placemark.administrativeArea {
                            self.locationDescription = "\(name), \(locality), \(adminArea)"
                        } else {
                            print("No matching address found")
                        }
                    }
                }
            }
        }
    }
    
    var locationDescription = "📍 No Location"
    
    // Check location authorization
    var isAuthorized: Bool {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        return isAuthorizedForLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // Check permission or request the current location
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    func checkPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.disallowedByUser {
            // Show alert to users
            print("error")
        } catch let error {
            print("Location Authorization error \(error.localizedDescription)")
        }
    }
    
    // MARK: Navigation
    
    // Back to Detail Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveLocationSegue" {
            let detailViewController = segue.destination as! DetailController
            if let coordinate = coordinate {
                detailViewController.coordinate = coordinate
                detailViewController.locationDescription = locationDescription
            }
        }
    }
}


// MARK: - Location Manager Delegate
extension LocationController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        adjustMap(with: coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        print(error)
    }
}


// MARK: - MapKit
extension LocationController {
    // Adjust the map around the current location and display an annotation at this location
    func adjustMap(with coordinate: Coordinate) {
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: 2500, longitudinalMeters: 2500)
        
        mapView.setRegion(region, animated: true)
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        mapView.addAnnotation(myAnnotation)
    }
}
