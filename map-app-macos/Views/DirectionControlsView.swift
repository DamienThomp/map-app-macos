//
//  DirectionControlsView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-12-14.
//

import SwiftUI
import MapKit

enum TransportOptions: String, CaseIterable {

    case automobile
    case walking
    case transit

    var optionType: MKDirectionsTransportType {

        switch self {
        case .automobile:
                .automobile
        case .walking:
                .walking
        case .transit:
                .transit
        }
    }

    var icon: Image {
        switch self {
        case .automobile:
            SymbolHelper.car.image
        case .walking:
            SymbolHelper.figureWalk.image
        case .transit:
            SymbolHelper.busFill.image
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .automobile:
            "Driving"
        case .walking:
            "Walking"
        case .transit:
            "Transit"
        }
    }
}

struct DirectionControlsView: View {

    @Environment(DirectionsStore.self) private var directionsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Button {
                directionsStore.dismissDirections()
            } label: {
                SymbolHelper.xmarkCircleFill.image
                    .imageScale(.small)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss directions")

            if case .failed(let message) = directionsStore.directionsState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                ForEach(TransportOptions.allCases, id: \.self) { option in
                    Button {
                        directionsStore.setTransportType(option.optionType)
                    } label: {
                        option.icon
                            .foregroundStyle(
                                directionsStore.transportType == option.optionType ? .white : .secondary
                            )
                    }
                    .background(directionsStore.transportType == option.optionType ? .blue : .clear)
                    .buttonStyle(.bordered)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .accessibilityLabel(option.accessibilityLabel)
                }
            }
        }
        .padding(8)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
}

#Preview {
    AppDependencies.make().installEnvironments(on: DirectionControlsView())
}
