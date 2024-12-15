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

    var icon: String {
        switch self {
        case .automobile:
            "car"
        case .walking:
            "figure.walk"
        case .transit:
            "bus.fill"
        }
    }
}

struct DirectionControlsView: View {
    
    @Environment(SearchResultsViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Button {
                viewModel.showingDirections = false
                viewModel.routes = []
            }
            label: {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.small)
            }.buttonStyle(.plain)

            HStack {
                ForEach(TransportOptions.allCases, id: \.self) { option in
                    Button {
                        viewModel.transportType = option.optionType
                    } label: {
                        Image(systemName: option.icon)
                            .foregroundStyle(viewModel.transportType == option.optionType ? .white : .secondary)
                    }.background(viewModel.transportType == option.optionType ? .blue : .clear)
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
