//
//  SideBar.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct SideBar: View {

    @Environment(LocationManager.self) private var locationManger
    @Environment(SearchResultsViewModel.self) private var searchResultsViewModel

    @State private var searchText: String = ""

    private func search() {
        Task {
            do {
                try await searchResultsViewModel.performSearch(
                    with: searchText,
                    for: locationManger.visibleRegion
                )
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {
        VStack {
            SearchResultsList()
        }
        .searchable(
            text: $searchText,
            placement: .sidebar,
            prompt: "Search"
        )
        .onChange(of: searchText) {
            if searchText.isEmpty {
                searchResultsViewModel.searchResults = []
            } else {
                search()
            }
        }.padding()
    }
}

#Preview {
    SideBar()
        .environment(LocationManager())
        .environment(SearchResultsViewModel())
}
