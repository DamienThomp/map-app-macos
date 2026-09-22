//
//  MarkerPopoverView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI
import MapKit

struct MarkerPopoverView: View {

    var viewModel: SearchResultsViewModel

    private var url: URL? {
        viewModel.selectedMapItem?.url
    }

    private var phoneNumber: URL? {
        guard let phoneNumber = viewModel.selectedMapItem?.phoneNumber else { return nil }

        let formattedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        return URL(string: "tel:\(formattedNumber)")
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {

                HStack(spacing: 10) {

                    Text(viewModel.selectedMapItem?.title ?? "").font(.title2)

                    if let phoneNumber {
                        Link(destination: phoneNumber) {
                            SymbolHelper.phone.image
                                .imageScale(.large)
                        }
                        .foregroundStyle(.gray)
                        .accessibilityLabel("Call location")
                    }

                    if let url {
                        Link(destination: url) {
                            SymbolHelper.safari.image
                                .imageScale(.large)
                        }
                        .foregroundStyle(.gray)
                        .accessibilityLabel("Open website")
                    }
                }.font(.caption)

                Button {
                    viewModel.requestDirections()
                } label: {
                    HStack {
                        Text("Get Directions")
                        SymbolHelper.arrowTriangleheadturnUpRightDiamond.image
                    }.padding(6)
                }
                .buttonStyle(.borderedProminent)
            }

            if let sceneErrorMessage = viewModel.sceneErrorMessage {
                Text(sceneErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                LookAroundPreview(initialScene: viewModel.scene)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(width: 300)
        .padding()
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 300)) {

    let locationManager = LocationManager()
    let viewModel = SearchResultsViewModel(locationManager: locationManager)

    MarkerPopoverView(viewModel: viewModel)
}
