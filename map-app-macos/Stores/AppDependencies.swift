//
//  AppDependencies.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import SwiftUI

@MainActor
struct AppDependencies {
    let locationManager: LocationManager
    let mapStore: MapStore
    let searchStore: SearchStore
    let placeStore: PlaceStore
    let directionsStore: DirectionsStore

    static func make() -> AppDependencies {
        let locationManager = LocationManager()
        let mapStore = MapStore()
        let searchStore = SearchStore(mapStore: mapStore)
        let placeStore = PlaceStore(mapStore: mapStore)
        let directionsStore = DirectionsStore(
            locationManager: locationManager,
            placeProvider: placeStore
        )

        locationManager.userLocationObserver = mapStore
        searchStore.placeSelecting = placeStore
        placeStore.directionsResetting = directionsStore

        return AppDependencies(
            locationManager: locationManager,
            mapStore: mapStore,
            searchStore: searchStore,
            placeStore: placeStore,
            directionsStore: directionsStore
        )
    }

    func installEnvironments(on content: some View) -> some View {
        content
            .environment(locationManager)
            .environment(mapStore)
            .environment(searchStore)
            .environment(placeStore)
            .environment(directionsStore)
    }
}
