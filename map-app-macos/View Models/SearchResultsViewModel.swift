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
        // TODO: add cache to avoid rate limit error
        scene = nil

        let request = MKLookAroundSceneRequest(coordinate: mapItem.coordinate)
        scene = try await request.scene
    }

    @MainActor 
    func updateSelectedItem(with id: UUID?) {
        
        selectedMapItem = nil

        guard let id,
              let mapItem = searchResults.first(where: { $0.id == id })
        else {
            return
        }
        
        selectedMapItem = mapItem
    }

    func updateRegion(with mapItem: PlaceAnnotation) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: mapItem.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
    }
}
