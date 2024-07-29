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
    @State private var selectedMapItem: MKMapItem?

    @Binding var searchResults: [PlaceAnnotation]

    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedMapItem) {
                ForEach(searchResults, id: \.id) { mapItem in
                    Marker(mapItem.title ?? "", coordinate: mapItem.coordinate)
                }
                UserAnnotation()
            }
        }
    }
}

#Preview {
    MapDetail(searchResults: .constant([])).environment(LocationManager())
}
