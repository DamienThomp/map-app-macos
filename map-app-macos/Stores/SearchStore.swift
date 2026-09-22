//
//  SearchStore.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class SearchStore {

    var searchQuery = ""
    var searchResults = [PlaceAnnotation]()
    var searchState: LoadState<[PlaceAnnotation]> = .idle

    @ObservationIgnored
    weak var placeSelecting: (any PlaceSelecting)?

    private let mapStore: MapStore
    private let searchCache = NSCache<NSString, MKLocalSearch.Response>()
    private var searchTask: Task<Void, Never>?

    init(mapStore: MapStore) {
        self.mapStore = mapStore
    }

    func clearSearch() {
        searchTask?.cancel()
        searchTask = nil
        searchQuery = ""
        searchResults = []
        searchState = .idle
        placeSelecting?.clearSelection()
    }

    func performSearch() {
        let searchTerm = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else {
            clearSearch()
            return
        }

        performSearch(with: searchTerm, for: mapStore.visibleRegion)
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

    private func executeSearch(with searchTerm: String, for visibleRegion: MKCoordinateRegion?) async throws {
        guard let region = visibleRegion else { return }

        let searchKey = searchCacheKey(term: searchTerm, region: region)

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

    private func searchCacheKey(term: String, region: MKCoordinateRegion) -> NSString {
        NSString(
            string: "\(term)|\(region.center.latitude),\(region.center.longitude)"
        )
    }

    private func updateSearch(_ searchResponse: MKLocalSearch.Response) {
        searchResults = searchResponse.mapItems.map(PlaceAnnotation.init)
    }
}
