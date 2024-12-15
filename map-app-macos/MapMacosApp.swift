//
//  MapMacosApp.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

@main
struct MapMacosApp: App {

    let locationManager: LocationManager
    let searchResultsViewModel: SearchResultsViewModel

    init() {
        locationManager = LocationManager()
        searchResultsViewModel = SearchResultsViewModel(locationManager: locationManager)
    }

    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
        .environment(locationManager)
        .environment(searchResultsViewModel)
    }
}
