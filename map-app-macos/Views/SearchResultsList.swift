//
//  SearchResultsList.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI
import MapKit

struct SearchResultsList: View {

    @Environment(LocationManager.self) private var locationManger
    @Environment(SearchResultsViewModel.self) private var searchResultsViewModel

    @State private var selection: UUID?

    var body: some View {

        List(selection: $selection) {
            if !searchResultsViewModel.searchResults.isEmpty {
                Section("Locations") {
                    ForEach(searchResultsViewModel.searchResults, id: \.id) { item in
                        SearchListCellView(
                            mapItem: item,
                            userLocation: locationManger.location
                        ).onTapGesture {
                            Task {
                                if selection == item.id {

                                    selection = nil
                                    try await Task.sleep(for: .seconds(0.5))
                                }

                                selection = item.id
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: selection) {
            searchResultsViewModel.updateSelectedItem(with: selection)
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    SearchResultsList().environment(LocationManager())
}
