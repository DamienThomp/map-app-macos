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

        Image(systemName: "mappin.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundStyle(.black, .pink)
            .onChange(of: selectedItem) {
                if selectedItem?.id == mapItem.id {
                    withAnimation(.easeInOut) {
                        showPopover = true
                    }
                }
            }
            .popover(isPresented: $showPopover) {
                MarkerPopoverView()
            }
    }
}
