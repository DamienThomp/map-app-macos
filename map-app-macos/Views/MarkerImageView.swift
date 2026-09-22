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
        placeStore.markerPresentation == .lookAround && isSelected
    }

    private var scaleEffect: CGFloat {
        if showPopover {
            return 1.8
        }

        if isSelected {
            return 1.5
        }

        return 1.0
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
            .padding(12)
            .onTapGesture {
                if isSelected {
                    placeStore.showLookAround()
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
                    placeStore.dismissMarkerPopover()
                }
            }
        )
    }
}
