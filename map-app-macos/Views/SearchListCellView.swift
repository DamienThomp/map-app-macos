//
//  SearchListCellView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI
import MapKit

struct SearchListCellView: View {

    let mapItem: PlaceAnnotation
    let userLocation: CLLocation?

    var body: some View {

        HStack(alignment: .firstTextBaseline) {

            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(.black, .pink)
            Text(mapItem.title ?? "")
                .font(.system(size: 14))

            Spacer()

            if let distance = mapItem.getDistance(userLocation: userLocation) {
                Text(distance, format: .measurement(width: .abbreviated))
                    .font(.system(size: 12))
                    .foregroundStyle(.cyan)
                    .opacity(0.4)
            }
        }
    }
}
