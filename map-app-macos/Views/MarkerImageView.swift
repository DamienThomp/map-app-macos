//
//  MarkerImageView.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-29.
//

import SwiftUI

struct MarkerImageView: View {

    @State private var showPopover: Bool = false

    var body: some View {

        Image(systemName: "mappin.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundStyle(.black, .pink)
            .onTapGesture {
                showPopover = true
            }
            .popover(isPresented: $showPopover) {
                MarkerPopoverView()
            }
    }
}

#Preview {
    MarkerImageView()
}
