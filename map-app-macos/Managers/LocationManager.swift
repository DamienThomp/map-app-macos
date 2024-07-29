//
//  LocationManager.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI
import CoreLocation
import Observation
import MapKit

@Observable
class LocationManager: NSObject {

    let manager = CLLocationManager()
    var location: CLLocation?
    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    var region: MKCoordinateRegion = MKCoordinateRegion()
    var visibleRegion: MKCoordinateRegion = MKCoordinateRegion()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let currentLocation = locations.first else { return }

        Task { @MainActor in
            location = currentLocation
            region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                latitudinalMeters: 500, longitudinalMeters: 500
            )
            position = .region(region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}

