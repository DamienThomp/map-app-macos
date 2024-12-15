//
//  SearchResultsViewModel.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import Foundation
import MapKit
import Observation

@Observable
class SearchResultsViewModel {

    @MainActor var searchResults = [PlaceAnnotation]()
    @MainActor var scene: MKLookAroundScene?
    @MainActor var selectedMapItem: PlaceAnnotation?
    @MainActor var routes = [MKRoute]()
    @MainActor var showingDirections: Bool = false

    var transportType: MKDirectionsTransportType = .automobile

    private var locationManager: LocationManager

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func performSearch(with searchTerm: String, for visibleRegion: MKCoordinateRegion?) async throws {

        guard let region = visibleRegion else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.resultTypes = .pointOfInterest
        request.region = region

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        Task { @MainActor in
            searchResults = response.mapItems.map(PlaceAnnotation.init)
        }
    }

    func getScene(with mapItem: PlaceAnnotation) async throws {

        let request = MKLookAroundSceneRequest(coordinate: mapItem.coordinate)
        let lookAroundScene = try await request.scene

        Task { @MainActor in
            scene = lookAroundScene
        }
    }

    func updateSelectedItem(with id: UUID?) {

        Task { @MainActor in

            selectedMapItem = nil

            guard let id,
                  let mapItem = searchResults.first(where: { $0.id == id })
            else {
                return
            }

            selectedMapItem = mapItem
        }
    }

    func getDirection() async throws {

        guard let selectedMapItem = await selectedMapItem,
            let location = locationManager.location else { return }

        let startPoint = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPoint))
        request.destination = MKMapItem(placemark: selectedMapItem.placeMark)
        request.transportType = transportType

        if transportType == .walking {
            request.requestsAlternateRoutes = true
        }

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        Task { @MainActor in
            routes = response.routes
        }
    }
}
