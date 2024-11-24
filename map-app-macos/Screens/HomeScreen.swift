//
//  HomeScreen.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct HomeScreen: View {

    let searchResultsViewModel = SearchResultsViewModel()
    let locationManager = LocationManager()

    var body: some View {
        NavigationSplitView {
            SideBar()
                .frame(minWidth: 300)
        } detail: {
            MapDetail()
        }
        .environment(locationManager)
        .environment(searchResultsViewModel)
    }
}

#Preview {
    HomeScreen()
}
