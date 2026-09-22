//
//  MapDetail.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI
import MapKit

struct MapDetail: View {

    @Environment(MapStore.self) private var mapStore
    @Environment(SearchStore.self) private var searchStore
    @Environment(PlaceStore.self) private var placeStore
    @Environment(DirectionsStore.self) private var directionsStore

    @Namespace var mapScope

    private var strokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: 12,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 10
        )
    }

    var body: some View {

        @Bindable var mapStore = mapStore
        @Bindable var searchStore = searchStore
        @Bindable var directionsStore = directionsStore

        ZStack {
            Map(
                position: $mapStore.position,
                interactionModes: .all,
                selection: placeStore.selectionBinding,
                scope: mapScope
            ) {

                ForEach(searchStore.searchResults, id: \.id) { mapItem in
                    Annotation(
                        mapItem.title ?? "",
                        coordinate: mapItem.coordinate
                    ) {
                        MarkerImageView(mapItem: mapItem)
                            .environment(placeStore)
                            .environment(directionsStore)
                    }
                    .tag(mapItem)
                }

                UserAnnotation()

                ForEach(directionsStore.routes, id: \.self) { element in
                    MapPolyline(element.polyline)
                        .stroke(
                            Gradient(colors: [.red, .indigo]),
                            style: strokeStyle
                        )
                }
            }
            .mapControls {
#if os(macOS)
                MapZoomStepper()
                MapPitchSlider()
#endif
                MapCompass()
            }
            .onMapCameraChange { context in
                mapStore.updateVisibleRegion(
                    context.region,
                    pitch: context.camera.pitch,
                    distance: context.camera.distance
                )
            }
            .toolbar {
                MapToolbarControls(mapStyle: $mapStore.mapStyle, mapScope: mapScope)
            }
            .overlay(alignment: .topTrailing) {
                if directionsStore.routes.first != nil {
                    DirectionControlsView()
                }
            }
            .mapStyle(mapStore.mapStyle)
        }
        .mapScope(mapScope)
    }
}

#Preview {
    AppDependencies.make().installEnvironments(on: MapDetail())
}
