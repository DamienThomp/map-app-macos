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
    @Environment(SearchResultsViewModel.self) private var searchResultsViewModel

    @Namespace var mapScope

    @State var mapStyle: MapStyle = .standard

    private func updateScene(with mapItem: PlaceAnnotation?) {
        Task {
            do {
                guard let mapItem else { return }
                try await searchResultsViewModel.getScene(with: mapItem)
            } catch {
                // TODO: handle updatescene error
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {

        @Bindable var viewModel = searchResultsViewModel
        @Bindable var location = locationManager

        ZStack {
            Map(
                position: $location.position,
                interactionModes: .all,
                selection: $viewModel.selectedMapItem,
                scope: mapScope
            ) {

                ForEach(searchResultsViewModel.searchResults, id: \.id) { mapItem in

                    Annotation(
                        mapItem.title ?? "",
                        coordinate: mapItem.coordinate
                    ) {
                        MarkerImageView(
                            selectedItem: $viewModel.selectedMapItem,
                            mapItem: mapItem
                        )
                    }
                    .tag(mapItem)
                }

                UserAnnotation()
            }
            .mapControls {

                MapZoomStepper()
                MapPitchSlider()
                MapCompass()
            }
            .onMapCameraChange { context in
                locationManager.visibleRegion = context.region
            }
            .onChange(of: viewModel.selectedMapItem) {

                if let selectedMapItem = viewModel.selectedMapItem {
                    
                    Task { @MainActor in
                        updateScene(with: selectedMapItem)
                        location.position = .region(viewModel.updateRegion(with: selectedMapItem))
                    }
                }
            }
            .toolbar {

                MapUserLocationButton(scope: mapScope)
                    .controlSize(.large)

                MapPitchToggle(scope: mapScope)
                    .mapControlVisibility(.visible)
                    .controlSize(.large)

                Menu {
                    Button {

                        mapStyle = .standard(
                            elevation: .flat,
                            showsTraffic: false
                        )
                    } label: {
                        Text("Standard")
                    }

                    Button {

                        mapStyle = .hybrid(
                            elevation: .realistic,
                            showsTraffic: true
                        )
                    } label: {
                        Text("Hydrid")
                    }
                } label: {
                    Image(systemName: "map")
                }
            }
            .mapStyle(mapStyle)
        }
        .mapScope(mapScope)
    }
}

#Preview {
    MapDetail()
        .environment(LocationManager())
        .environment(SearchResultsViewModel())
}
