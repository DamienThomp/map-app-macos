//
//  MarkerPopoverView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI
import MapKit

struct MarkerPopoverView: View {

    @Environment(PlaceStore.self) private var placeStore
    @Environment(DirectionsStore.self) private var directionsStore

    private var url: URL? {
        placeStore.selectedPlace?.url
    }

    private var phoneNumber: URL? {
        guard let phoneNumber = placeStore.selectedPlace?.phoneNumber else { return nil }

        let formattedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        return URL(string: "tel:\(formattedNumber)")
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {

                HStack(spacing: 10) {

                    Text(placeStore.selectedPlace?.title ?? "").font(.title2)

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
                    directionsStore.requestDirections()
                } label: {
                    HStack {
                        Text("Get Directions")
                        SymbolHelper.arrowTriangleheadturnUpRightDiamond.image
                    }.padding(6)
                }
                .buttonStyle(.borderedProminent)
            }

            if let sceneErrorMessage = placeStore.sceneErrorMessage {
                Text(sceneErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                LookAroundPreview(initialScene: placeStore.lookAroundScene)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(width: 300)
        .padding()
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 300)) {
    AppDependencies.make().installEnvironments(on: MarkerPopoverView())
}
