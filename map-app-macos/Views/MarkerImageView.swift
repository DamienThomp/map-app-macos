//
//  MarkerImageView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI

struct MarkerImageView: View {

    @State private var showPopover: Bool = false
    @Binding var selectedItem: PlaceAnnotation?

    let mapItem: PlaceAnnotation

    var body: some View {

        Image(systemName: mapItem.pointOfInterestIcon)
            .resizable()
            .scaledToFit()
            .scaleEffect(showPopover ? 1.8 : 1.0)
            .frame(width: 30, height: 30)
            .foregroundStyle(.black, mapItem.pointOfInterestColor)
            .onChange(of: selectedItem) {
                if selectedItem?.id == mapItem.id {
                    withAnimation(.easeInOut) {
                        showPopover = true
                    }
                }
            }
            .padding(12)
            .popover(isPresented: $showPopover, arrowEdge: .leading) {
                MarkerPopoverView()
            }
            .animation(.spring(duration: 0.5, bounce: 0.75), value: showPopover)
    }
}
