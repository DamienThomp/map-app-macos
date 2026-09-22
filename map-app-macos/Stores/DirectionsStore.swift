//
//  DirectionsStore.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import CoreLocation
import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class DirectionsStore: DirectionsResetting {

    var routes = [MKRoute]()
    var transportType: MKDirectionsTransportType = .automobile
    var directionsState: LoadState<[MKRoute]> = .idle

    private let locationManager: LocationManager
    private let placeProvider: PlaceProviding
    private var directionsTask: Task<Void, Never>?

    init(locationManager: LocationManager, placeProvider: PlaceProviding) {
        self.locationManager = locationManager
        self.placeProvider = placeProvider
    }

    func requestDirections() {
        placeProvider.setMarkerPresentation(.directions)
        directionsTask?.cancel()
        directionsTask = Task {
            directionsState = .loading
            do {
                try await executeDirections()
                try Task.checkCancellation()
                directionsState = .loaded(routes)
            } catch is CancellationError {
                return
            } catch {
                directionsState = .failed(error.localizedDescription)
                if placeProvider.lookAroundScene != nil {
                    placeProvider.setMarkerPresentation(.lookAround)
                }
            }
        }
    }

    func setTransportType(_ type: MKDirectionsTransportType) {
        transportType = type
        if !routes.isEmpty {
            requestDirections()
        }
    }

    func dismissDirections() {
        directionsTask?.cancel()
        routes = []
        transportType = .automobile
        directionsState = .idle
        if placeProvider.selectedPlace != nil {
            placeProvider.setMarkerPresentation(.lookAround)
        } else {
            placeProvider.setMarkerPresentation(.none)
        }
    }

    func resetDirections() {
        directionsTask?.cancel()
        routes = []
        transportType = .automobile
        directionsState = .idle
    }

    private func executeDirections() async throws {
        guard let selectedPlace = placeProvider.selectedPlace,
              let location = locationManager.location else {
            throw DirectionsError.missingLocationOrDestination
        }

        let request = MKDirections.Request()
        if #available(macOS 26.0, iOS 18.0, *) {
            request.source = MKMapItem(location: location, address: nil)
        } else {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        }
        request.destination = selectedPlace.mapItem
        request.transportType = transportType

        if transportType == .walking {
            request.requestsAlternateRoutes = true
        }

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        try Task.checkCancellation()
        routes = response.routes
    }
}

private enum DirectionsError: LocalizedError {
    case missingLocationOrDestination

    var errorDescription: String? {
        switch self {
        case .missingLocationOrDestination:
            "Location or destination is unavailable."
        }
    }
}
