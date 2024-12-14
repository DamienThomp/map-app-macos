//
//  MarkerImageView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI
import MapKit

struct MarkerImageView: View {

    @State private var showPopover: Bool = false
    @Binding var selectedItem: PlaceAnnotation?
    @Binding var scene: MKLookAroundScene?
    @Binding var route: [MKRoute]

    let mapItem: PlaceAnnotation

    var body: some View {

        Image(systemName: mapItem.pointOfInterestIcon)
            .resizable()
            .scaledToFit()
            .scaleEffect(showPopover ? 1.8 : 1.0)
            .frame(width: 30, height: 30)
            .foregroundStyle(.black, mapItem.pointOfInterestColor)
            .onChange(of: scene) {
                if selectedItem?.id == mapItem.id {
                    withAnimation(.easeInOut) {
                        showPopover = true
                    }
                }
            }
            .onChange(of: route) {
                showPopover = false
            }
            .onTapGesture {
                if selectedItem?.id == mapItem.id {
                    withAnimation(.easeInOut) {
                        showPopover = true
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Gradient(colors: [.gray, .black]), lineWidth: 2)
                    .scaleEffect(showPopover ? 1.8 : 1.0)
            )
            .padding(12)
            .popover(isPresented: $showPopover, arrowEdge: .leading) {
                MarkerPopoverView()
            }
            .animation(.spring(duration: 0.5, bounce: 0.75), value: showPopover)
    }
}
