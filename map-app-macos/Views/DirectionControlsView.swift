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

    @Environment(SearchResultsViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Button {
                viewModel.dismissDirections()
            } label: {
                SymbolHelper.xmarkCircleFill.image
                    .imageScale(.small)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss directions")

            if case .failed(let message) = viewModel.directionsState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                ForEach(TransportOptions.allCases, id: \.self) { option in
                    Button {
                        viewModel.setTransportType(option.optionType)
                    } label: {
                        option.icon
                            .foregroundStyle(viewModel.transportType == option.optionType ? .white : .secondary)
                    }
                    .background(viewModel.transportType == option.optionType ? .blue : .clear)
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

    let locationManager = LocationManager()
    let viewModel = SearchResultsViewModel(locationManager: locationManager)

    DirectionControlsView().environment(viewModel)
}
