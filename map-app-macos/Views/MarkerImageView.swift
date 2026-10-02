//
//  MarkerImageView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI
import MapKit

struct MarkerImageView: View {

    @Environment(PlaceStore.self) private var placeStore
    @Environment(DirectionsStore.self) private var directionsStore
    let mapItem: PlaceAnnotation

    private var isSelected: Bool {
        placeStore.selectedPlace?.id == mapItem.id
    }

    private var showPopover: Bool {
        isSelected && placeStore.isPopoverPresented
    }

    private var scaleEffect: CGFloat {
        showPopover ? 1.8 : 1.0
    }

    var body: some View {

        Image(systemName: mapItem.pointOfInterestIcon)
            .resizable()
            .scaledToFit()
            .scaleEffect(scaleEffect)
            .frame(width: 30, height: 30)
            .foregroundStyle(
                .black.gradient,
                mapItem.pointOfInterestColor.gradient
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Gradient(colors: [mapItem.pointOfInterestColor, .black]), lineWidth: 2)
                    .scaleEffect(scaleEffect)
            )
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                if isSelected {
                    placeStore.presentPopover()
                } else {
                    placeStore.select(mapItem)
                }
            }
            .popover(isPresented: popoverBinding) {
                MarkerPopoverView()
                    .environment(placeStore)
                    .environment(directionsStore)
            }
            .animation(.spring(duration: 0.5, bounce: 0.75), value: showPopover)
    }

    private var popoverBinding: Binding<Bool> {
        Binding(
            get: { showPopover },
            set: { isPresented in
                if !isPresented {
                    placeStore.dismissPopover()
                }
            }
        )
    }
}
