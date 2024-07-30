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

    private var task: Task<(), Never>?

    var body: some View {

        List(selection: $selection) {
            if !searchResultsViewModel.searchResults.isEmpty {
                Section("Locations") {
                    ForEach(searchResultsViewModel.searchResults, id: \.id) { item in
                        SearchListCellView(
                            mapItem: item,
                            userLocation: locationManger.location
                        ).onTapGesture {
                            // TODO: find a better solution to reseting selection value
                            selection = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
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
