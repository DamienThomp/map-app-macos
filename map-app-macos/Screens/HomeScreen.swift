//
//  HomeScreen.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct HomeScreen: View {

    @State private var searchResults: [PlaceAnnotation] = []

    let locationManger = LocationManager()

    var body: some View {
        NavigationSplitView {
            SideBar(searchResults: $searchResults)
                .frame(minWidth: 300)
        } detail: {
            MapDetail(searchResults: $searchResults)
        }
        .environment(locationManger)

    }
}

#Preview {
    HomeScreen()
}
