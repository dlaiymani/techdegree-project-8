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
    
    var geocoder = CLGeocoder()
    var coordinate: Coordinate? {
        didSet {
            if let coordinate = coordinate {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
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
    
    var isAuthorized: Bool {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        return isAuthorizedForLocation
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
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
    func adjustMap(with coordinate: Coordinate) {
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: 2500, longitudinalMeters: 2500)
        
        // let region = MKCoordinateRegion.init(center: coordinate2D, span: span)
        mapView.setRegion(region, animated: true)
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        mapView.addAnnotation(myAnnotation)
    }
}
