//
//  SearchResultsList.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI
import MapKit

struct SearchResultsList: View {

    @Environment(LocationManager.self) private var locationManger

    let searchResult: [PlaceAnnotation]

    var body: some View {
        List {
            Section("Locations") {
                ForEach(searchResult, id: \.id) { item in
                    VStack(alignment: .leading) {
                        Text(item.title ?? "")
                        if let distance = item.getDistance(userLocation: locationManger.location) {
                            Text(distance, format: .measurement(width: .abbreviated))
                                .foregroundStyle(.cyan)
                                .opacity(0.4)
                        }
                    }
                }
            }
        }.listStyle(.sidebar)
    }
}

#Preview {
    SearchResultsList(searchResult: []).environment(LocationManager())
}
