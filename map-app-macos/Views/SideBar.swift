//
//  SideBar.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct SideBar: View {

    @Environment(LocationManager.self) private var locationManager
    @Environment(SearchResultsViewModel.self) private var searchResultsViewModel

    @State private var searchText: String = ""

    var body: some View {

        @Bindable var viewModel = searchResultsViewModel

        VStack {
            if case .loading = viewModel.searchState {
                ProgressView("Searching…")
                    .padding(.vertical, 8)
            }

            if case .failed(let message) = viewModel.searchState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.vertical, 4)
            }

            SearchResultsList()
        }
        .searchable(
            text: $searchText,
            placement: .sidebar,
            prompt: "Search"
        )
        .onChange(of: searchText) {
            if searchText.isEmpty {
                searchResultsViewModel.clearSearchResults()
            } else {
                searchResultsViewModel.performSearch(
                    with: searchText,
                    for: locationManager.visibleRegion
                )
            }
        }.padding()
    }
}

#Preview {

    let locationManager = LocationManager()
    let viewModel = SearchResultsViewModel(locationManager: locationManager)

    SideBar()
        .environment(locationManager)
        .environment(viewModel)
}
