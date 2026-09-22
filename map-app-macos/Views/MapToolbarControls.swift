//
//  MapToolbarControls.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import SwiftUI
import MapKit

struct MapToolbarControls: View {

    @Binding var mapStyle: MapStyle
    var mapScope: Namespace.ID

    var body: some View {
        MapUserLocationButton(scope: mapScope)
            .controlSize(.large)
            .accessibilityLabel("Show my location")

        MapPitchToggle(scope: mapScope)
            .mapControlVisibility(.visible)
            .controlSize(.large)
            .accessibilityLabel("Toggle map pitch")

        Menu {
            Button {
                mapStyle = .standard(
                    elevation: .flat,
                    showsTraffic: false
                )
            } label: {
                Text("Standard")
            }

            Button {
                mapStyle = .hybrid(
                    elevation: .realistic,
                    showsTraffic: true
                )
            } label: {
                Text("Hybrid")
            }
        } label: {
            SymbolHelper.map.image
        }
        .accessibilityLabel("Map style")
    }
}
