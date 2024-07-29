//
//  SearchResultsViewModel.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import Foundation
import MapKit
import Observation

class SearchResultsViewModel {

    private var locationManger = LocationManager()

    func performSearch(with searchTerm: String, for visibleRegion: MKCoordinateRegion?) async throws -> [PlaceAnnotation] {

        guard let region = visibleRegion else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.resultTypes = .pointOfInterest
        request.region = region

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.map(PlaceAnnotation.init)
    }
}
