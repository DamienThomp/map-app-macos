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
    @Environment(\.openURL) var openUrl

    private var url: URL? {
       searchResultsViewModel.selectedMapItem?.url
    }

    private var phoneNumber: URL? {

        guard let phoneNumber = searchResultsViewModel.selectedMapItem?.phoneNumber else { return nil }

        let formattedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        return URL(string: "tel:\(formattedNumber)")
    }

    var body: some View {

        @Bindable var viewModel = searchResultsViewModel
        
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {
                Text(viewModel.selectedMapItem?.title ?? "").font(.title2)
                HStack(spacing: 10) {

                    if let phoneNumber {
                        Link(destination: phoneNumber ) {
                            Image(systemName: "phone")
                        }.foregroundStyle(.gray)
                    }

                    if let url {
                        Link(destination: url ) {
                            Image(systemName: "safari")
                        }.foregroundStyle(.gray)
                    }
                }.font(.caption)
            }

            LookAroundPreview(scene: $viewModel.scene)
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
