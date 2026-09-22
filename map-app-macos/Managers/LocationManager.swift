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

@MainActor
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    @ObservationIgnored
    private nonisolated(unsafe) var locationUpdatesTask: Task<Void, Never>?

    var location: CLLocation?
    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    var region: MKCoordinateRegion = MKCoordinateRegion()
    var visibleRegion: MKCoordinateRegion = MKCoordinateRegion()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        handleAuthorizationChange()
    }

    deinit {
        locationUpdatesTask?.cancel()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            handleAuthorizationChange()
        }
    }

    private func handleAuthorizationChange() {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationUpdatesTask?.cancel()
            locationUpdatesTask = nil
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        @unknown default:
            break
        }
    }

    private func startLocationUpdates() {
        locationUpdatesTask?.cancel()
        locationUpdatesTask = Task {
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    try Task.checkCancellation()
                    guard let currentLocation = update.location else { continue }

                    location = currentLocation
                    region = MKCoordinateRegion(
                        center: currentLocation.coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    )
                    position = .region(region)
                }
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }
}
