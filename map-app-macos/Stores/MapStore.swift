//
//  MapStore.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
final class MapStore: UserLocationObserving {

    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    var visibleRegion: MKCoordinateRegion = MKCoordinateRegion()
    var mapStyle: MapStyle = .standard
    var currentPitch: CGFloat = 0
    var currentDistance: CGFloat = 1000

    func userLocationDidUpdate(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        position = .region(region)
    }

    func updateVisibleRegion(_ region: MKCoordinateRegion, pitch: CGFloat, distance: CGFloat) {
        visibleRegion = region
        currentPitch = pitch
        currentDistance = distance
    }

    func focus(on coordinate: CLLocationCoordinate2D, completion: (() -> Void)? = nil) {
        if isCoordinateNearCenter(coordinate) {
            completion?()
            return
        }

        let mapCamera = MapCamera(
            centerCoordinate: coordinate,
            distance: currentDistance,
            pitch: currentPitch
        )

        withAnimation {
            position = .camera(mapCamera)
        } completion: {
            completion?()
        }
    }

    private func isCoordinateNearCenter(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let region = visibleRegion
        guard region.span.latitudeDelta > 0, region.span.longitudeDelta > 0 else {
            return false
        }

        let latThreshold = region.span.latitudeDelta * 0.05
        let lonThreshold = region.span.longitudeDelta * 0.05

        return abs(coordinate.latitude - region.center.latitude) < latThreshold
            && abs(coordinate.longitude - region.center.longitude) < lonThreshold
    }
}
