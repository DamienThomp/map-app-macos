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
    
    @MainActor
    private var url: String? {
        searchResultsViewModel.selectedMapItem?.url?.absoluteString
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
                        Text(url)
                            .foregroundStyle(.blue)
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
