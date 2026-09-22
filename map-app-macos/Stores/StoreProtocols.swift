//
//  StoreProtocols.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import CoreLocation
import Foundation
import MapKit

@MainActor
protocol PlaceSelecting: AnyObject {
    func clearSelection()
}

@MainActor
protocol DirectionsResetting: AnyObject {
    func resetDirections()
}

@MainActor
protocol UserLocationObserving: AnyObject {
    func userLocationDidUpdate(_ location: CLLocation)
}

@MainActor
protocol PlaceProviding: AnyObject {
    var selectedPlace: PlaceAnnotation? { get }
    var lookAroundScene: MKLookAroundScene? { get }
    func setMarkerPresentation(_ presentation: MarkerPresentation)
}
