//
//  MarkerPopoverView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI
import MapKit

struct MarkerPopoverView: View {

    @Environment(SearchResultsViewModel.self) var searchResultsViewModel

    private var url: URL? {
        searchResultsViewModel.selectedMapItem?.url
    }

    private var phoneNumber: URL? {

        guard let phoneNumber = searchResultsViewModel.selectedMapItem?.phoneNumber else { return nil }

        let formattedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        return URL(string: "tel:\(formattedNumber)")
    }

    private func getDirections() {
        Task {
            do {
                try await searchResultsViewModel.getDirection()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {

                HStack(spacing: 10) {
                    
                    Text(searchResultsViewModel.selectedMapItem?.title ?? "").font(.title2)

                    if let phoneNumber {
                        Link(destination: phoneNumber ) {
                            Image(systemName: "phone")
                                .imageScale(.large)
                        }.foregroundStyle(.gray)
                    }

                    if let url {
                        Link(destination: url ) {
                            Image(systemName: "safari")
                                .imageScale(.large)
                        }.foregroundStyle(.gray)
                    }
                }.font(.caption)

                Button {
                    searchResultsViewModel.showingDirections = false
                    getDirections()
                    searchResultsViewModel.showingDirections = true
                } label: {
                    HStack {
                        Text("Get Directions")
                        Image(systemName: "arrow.trianglehead.turn.up.right.diamond")
                    }.padding(6)
                }.buttonStyle(.borderedProminent)
            }

            LookAroundPreview(initialScene: searchResultsViewModel.scene)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: 300)
        .padding()
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 300)) {
    
    let locationManager = LocationManager()
    let viewModel = SearchResultsViewModel(locationManager: locationManager)

    MarkerPopoverView()
        .environment(viewModel)
}
