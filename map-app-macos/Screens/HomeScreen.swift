//
//  HomeScreen.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct HomeScreen: View {

    var body: some View {
        NavigationSplitView {
            SideBar()
                .frame(minWidth: 300)
        } detail: {
            MapDetail()
        }
    }
}

#Preview {

    let locationManager = LocationManager()
    let viewModel = SearchResultsViewModel(locationManager: locationManager)

    HomeScreen()
        .environment(locationManager)
        .environment(viewModel)
}
