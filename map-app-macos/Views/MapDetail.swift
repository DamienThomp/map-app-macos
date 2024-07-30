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

    private func updateScene(with mapItem: PlaceAnnotation?) {
        Task {
            do {
                guard let mapItem else { return }
                try await searchResultsViewModel.getScene(with: mapItem)
            } catch {
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
                selection: $viewModel.selectedMapItem
            ) {

                ForEach(searchResultsViewModel.searchResults, id: \.id) { mapItem in

                    Annotation(
                        mapItem.title ?? "",
                        coordinate: mapItem.coordinate
                    ) {
                        MarkerImageView(selectedItem: $viewModel.selectedMapItem, mapItem: mapItem)
                    }
                    .tag(mapItem)
                }

                UserAnnotation()
            }
            .mapControls {
                MapPitchSlider()
                MapUserLocationButton()
                MapCompass()
            }
            .onMapCameraChange { context in
                locationManager.visibleRegion = context.region
            }
            .onChange(of: viewModel.selectedMapItem) {
                if let selectedMapItem = viewModel.selectedMapItem {
                    updateScene(with: selectedMapItem)
                    location.position = .region(viewModel.updateRegion(with: selectedMapItem))
                }
            }
        }
    }
}

#Preview {
    MapDetail()
        .environment(LocationManager())
        .environment(SearchResultsViewModel())
}
