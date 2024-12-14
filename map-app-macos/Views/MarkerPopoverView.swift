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

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {
                Text(searchResultsViewModel.selectedMapItem?.title ?? "").font(.title2)
                HStack(spacing: 10) {

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
    MarkerPopoverView()
        .environment(SearchResultsViewModel())
}
