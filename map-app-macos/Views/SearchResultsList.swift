//
//  SearchResultsList.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI
import MapKit

struct SearchResultsList: View {

    @Environment(LocationManager.self) private var locationManager
    @Environment(SearchResultsViewModel.self) private var searchResultsViewModel

    var body: some View {

        @Bindable var viewModel = searchResultsViewModel

        List(selection: $viewModel.selectedMapItem) {
            if !viewModel.searchResults.isEmpty {
                Section("Locations") {
                    ForEach(viewModel.searchResults, id: \.id) { item in
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
    SearchResultsList()
        .environment(LocationManager())
        .environment(SearchResultsViewModel(locationManager: LocationManager()))
}
