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
    var selectedMapItem: PlaceAnnotation?

    private var locationManger = LocationManager()

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

    @MainActor 
    func getScene(with mapItem: PlaceAnnotation) async throws {

        scene = nil

        let request = MKLookAroundSceneRequest(coordinate: mapItem.coordinate)
        scene = try await request.scene

    }

    func updateRegion(with mapItem: PlaceAnnotation) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: mapItem.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
    }
}
