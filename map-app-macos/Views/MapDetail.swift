//
//  MapDetail.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI
import MapKit

struct MapDetail: View {
    
    @Environment(LocationManager.self) private var locationManager
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedMapItem: PlaceAnnotation?

    @Binding var searchResults: [PlaceAnnotation]

    var body: some View {
        ZStack {
            Map(
                position: $position,
                interactionModes: .all,
                selection: $selectedMapItem
            ) {

                ForEach(searchResults, id: \.id) { mapItem in
                    Marker(
                        mapItem.title ?? "",
                        coordinate: mapItem.coordinate
                    ).tag(mapItem)
                }

                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapPitchSlider()
            }
            .onMapCameraChange { context in
                locationManager.visibleRegion = context.region
            }.onChange(of: selectedMapItem) {
               print("Handle Look around preview here")
            }
        }
    }
}

#Preview {
    MapDetail(searchResults: .constant([])).environment(LocationManager())
}
