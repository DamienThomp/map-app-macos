//
//  SearchResultsViewModel.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class SearchResultsViewModel {

    var searchResults = [PlaceAnnotation]()
    var scene: MKLookAroundScene?
    var selectedMapItem: PlaceAnnotation?
    var routes = [MKRoute]()
    var showingDirections: Bool = false
    var transportType: MKDirectionsTransportType = .automobile

    let sceneCache = NSCache<NSString, MKLookAroundScene>()
    let searchCache = NSCache<NSString, MKLocalSearch.Response>()

    private let locationManager: LocationManager
    private var searchTask: Task<Void, Never>?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func clearSearchResults() {
        searchTask?.cancel()
        searchTask = nil
        searchResults = []
    }

    func performSearch(with searchTerm: String, for visibleRegion: MKCoordinateRegion?) {
        searchTask?.cancel()
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()
                try await executeSearch(with: searchTerm, for: visibleRegion)
            } catch is CancellationError {
                return
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func getScene(with mapItem: PlaceAnnotation) async throws {
        let coordinateKey = NSString(string: "\(mapItem.coordinate.latitude),\(mapItem.coordinate.longitude)")

        if let cachedScene = sceneCache.object(forKey: coordinateKey) {
            updateScene(cachedScene)
            return
        }

        let request = MKLookAroundSceneRequest(coordinate: mapItem.coordinate)
        let lookAroundScene = try await request.scene

        try Task.checkCancellation()

        if let lookAroundScene {
            sceneCache.setObject(lookAroundScene, forKey: coordinateKey)
            updateScene(lookAroundScene)
        }
    }

    func updateSelectedItem(with id: UUID?) {
        selectedMapItem = nil

        guard let id,
              let mapItem = searchResults.first(where: { $0.id == id })
        else {
            return
        }

        selectedMapItem = mapItem
    }

    func getDirection() async throws {
        guard let selectedMapItem,
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

        try Task.checkCancellation()
        routes = response.routes
    }

    func resetDirections() {
        routes = []
        transportType = .automobile
    }

    private func executeSearch(with searchTerm: String, for visibleRegion: MKCoordinateRegion?) async throws {
        guard let region = visibleRegion else { return }

        let searchKey = NSString(string: searchTerm)

        if let searchResultCache = searchCache.object(forKey: searchKey) {
            updateSearch(searchResultCache)
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.resultTypes = .pointOfInterest
        request.region = region

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        try Task.checkCancellation()

        searchCache.setObject(response, forKey: searchKey)
        updateSearch(response)
    }

    private func updateScene(_ lookAroundScene: MKLookAroundScene) {
        scene = lookAroundScene
    }

    private func updateSearch(_ searchResponse: MKLocalSearch.Response) {
        searchResults = searchResponse.mapItems.map(PlaceAnnotation.init)
    }
}
