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
    var markerPresentation: MarkerPresentation = .none

    var searchState: LoadState<[PlaceAnnotation]> = .idle
    var directionsState: LoadState<[MKRoute]> = .idle
    var sceneErrorMessage: String?

    let sceneCache = NSCache<NSString, MKLookAroundScene>()
    let searchCache = NSCache<NSString, MKLocalSearch.Response>()

    private let locationManager: LocationManager
    private var searchTask: Task<Void, Never>?
    private var directionsTask: Task<Void, Never>?
    private var sceneTask: Task<Void, Never>?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func clearSearchResults() {
        searchTask?.cancel()
        searchTask = nil
        searchResults = []
        searchState = .idle
    }

    func performSearch(with searchTerm: String, for visibleRegion: MKCoordinateRegion?) {
        searchTask?.cancel()
        searchTask = Task {
            searchState = .loading
            do {
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()
                try await executeSearch(with: searchTerm, for: visibleRegion)
                searchState = .loaded(searchResults)
            } catch is CancellationError {
                return
            } catch {
                searchState = .failed(error.localizedDescription)
            }
        }
    }

    func selectItem(_ item: PlaceAnnotation?) {
        if selectedMapItem?.id != item?.id {
            scene = nil
            sceneTask?.cancel()
        }

        selectedMapItem = item
        markerPresentation = .none

        if item == nil {
            scene = nil
            sceneTask?.cancel()
        }
    }

    func loadScene(for mapItem: PlaceAnnotation) {
        sceneTask?.cancel()
        sceneErrorMessage = nil
        sceneTask = Task {
            do {
                try await getScene(with: mapItem)
                try Task.checkCancellation()
                guard selectedMapItem?.id == mapItem.id else { return }
                markerPresentation = .lookAround
            } catch is CancellationError {
                return
            } catch {
                guard selectedMapItem?.id == mapItem.id else { return }
                sceneErrorMessage = error.localizedDescription
                markerPresentation = .none
            }
        }
    }

    func dismissMarkerPopover() {
        if markerPresentation == .lookAround {
            markerPresentation = .none
        }
    }

    func requestDirections() {
        markerPresentation = .directions
        showingDirections = true
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
                if scene != nil {
                    markerPresentation = .lookAround
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
        showingDirections = false
        routes = []
        transportType = .automobile
        directionsState = .idle
        if selectedMapItem != nil {
            markerPresentation = .lookAround
        } else {
            markerPresentation = .none
        }
    }

    func resetDirections() {
        directionsTask?.cancel()
        routes = []
        transportType = .automobile
        directionsState = .idle
        showingDirections = false
    }

    private func getScene(with mapItem: PlaceAnnotation) async throws {
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

    private func executeDirections() async throws {
        guard let selectedMapItem,
              let location = locationManager.location else {
            throw DirectionsError.missingLocationOrDestination
        }

        let request = MKDirections.Request()
        if #available(macOS 26.0, iOS 18.0, *) {
            request.source = MKMapItem(location: location, address: nil)
        } else {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        }
        request.destination = selectedMapItem.mapItem
        request.transportType = transportType

        if transportType == .walking {
            request.requestsAlternateRoutes = true
        }

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        try Task.checkCancellation()
        routes = response.routes
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

private enum DirectionsError: LocalizedError {
    case missingLocationOrDestination

    var errorDescription: String? {
        switch self {
        case .missingLocationOrDestination:
            "Location or destination is unavailable."
        }
    }
}
