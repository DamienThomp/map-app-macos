//
//  SideBar.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct SideBar: View {

    @Environment(LocationManager.self) private var locationManger

    @State private var searchText: String = ""
    @State private var viewModel = SearchResultsViewModel()

    @Binding var searchResults: [PlaceAnnotation]

    private func search() {
        Task {
            do {
                searchResults = try await viewModel.performSearch(
                    with: searchText,
                    for: locationManger.visibleRegion
                )
            } catch {
                print(error.localizedDescription)
                searchResults = []
            }
        }
    }

    var body: some View {
        VStack {
            SearchResultsList(searchResult: searchResults)
        }
        .searchable(
            text: $searchText,
            placement: .sidebar,
            prompt: "Search"
        )
        .onChange(of: searchText) {
            if searchText.isEmpty {
                searchResults = []
            } else {
                search()
            }
        }.padding()
    }
}

#Preview {
    SideBar(searchResults: .constant([]))
        .environment(LocationManager())
}
