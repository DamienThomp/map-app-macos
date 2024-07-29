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

    var body: some View {
        List {
            if !searchResultsViewModel.searchResults.isEmpty {
                Section("Locations") {
                    ForEach(searchResultsViewModel.searchResults, id: \.id) { item in
                        VStack(alignment: .leading) {
                            Text(item.title ?? "")
                            if let distance = item.getDistance(userLocation: locationManger.location) {
                                Text(distance, format: .measurement(width: .abbreviated))
                                    .foregroundStyle(.cyan)
                                    .opacity(0.4)
                            }
                        }.onTapGesture {
                            searchResultsViewModel.selectedMapItem = item
                        }
                    }
                }
            }
        }.listStyle(.sidebar)
    }
}

#Preview {
    SearchResultsList().environment(LocationManager())
}
