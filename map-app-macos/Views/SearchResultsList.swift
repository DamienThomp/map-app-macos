//
//  SearchResultsList.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct SearchResultsList: View {

    @Environment(LocationManager.self) private var locationManager
    @Environment(SearchStore.self) private var searchStore
    @Environment(PlaceStore.self) private var placeStore

    var body: some View {

        @Bindable var searchStore = searchStore

        List(selection: placeStore.selectionBinding) {
            if !searchStore.searchResults.isEmpty {
                Section("Locations") {
                    ForEach(searchStore.searchResults, id: \.id) { item in
                        SearchListCellView(
                            mapItem: item,
                            userLocation: locationManager.location
                        )
                        .tag(item)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    AppDependencies.make().installEnvironments(on: SearchResultsList())
}
