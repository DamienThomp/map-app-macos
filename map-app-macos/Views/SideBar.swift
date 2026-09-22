//
//  SideBar.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

struct SideBar: View {

    @Environment(SearchStore.self) private var searchStore

    var body: some View {

        @Bindable var searchStore = searchStore

        VStack {
            if case .loading = searchStore.searchState {
                ProgressView("Searching…")
                    .padding(.vertical, 8)
            }

            if case .failed(let message) = searchStore.searchState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.vertical, 4)
            }

            SearchResultsList()
        }
        .searchable(
            text: $searchStore.searchQuery,
            placement: .sidebar,
            prompt: "Search"
        )
        .onChange(of: searchStore.searchQuery) {
            if searchStore.searchQuery.isEmpty {
                searchStore.clearSearch()
            } else {
                searchStore.performSearch()
            }
        }
        .padding()
    }
}

#Preview {
    AppDependencies.make().installEnvironments(on: SideBar())
}
