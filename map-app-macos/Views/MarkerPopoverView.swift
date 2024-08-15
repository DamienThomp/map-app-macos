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

    @MainActor
    private var url: URL? {
        searchResultsViewModel.selectedMapItem?.url
    }

    @MainActor
    private var phoneNumber: String? {
        searchResultsViewModel.selectedMapItem?.phoneNumber
    }

    var body: some View {

        @Bindable var viewModel = searchResultsViewModel
        
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {
                Text(viewModel.selectedMapItem?.title ?? "").font(.title2)
                HStack(spacing: 10) {

                    if let phoneNumber {
                        Text(phoneNumber)
                    }

                    if let url {
                        Button {
                            openUrl(url)
                        } label: {
                            Text(url.absoluteString)
                        }.buttonStyle(.borderless)
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
