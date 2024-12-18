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
    @State var currentPitch: CGFloat = 0.0
    @State var currentDistance: CGFloat = 1000

    private var strokeStyle: StrokeStyle {

        StrokeStyle(
            lineWidth: 12,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 10
        )
    }

    private func updateScene(with mapItem: PlaceAnnotation?) {

        Task {
            do {
                guard let mapItem else { return }
                
                try await searchResultsViewModel.getScene(with: mapItem)
            } catch {
                print("update scene error: \(error.localizedDescription)")
            }
        }
    }

    private func createCamera(
        with coordinate: CLLocationCoordinate2D,
        pitch: CGFloat,
        distance: CGFloat
    ) -> MapCamera {

        MapCamera(
            centerCoordinate: coordinate,
            distance: distance,
            pitch: pitch
        )
    }

    private func getDirections() {
        Task {
            do {
                try await searchResultsViewModel.getDirection()
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
                            scene: $viewModel.scene,
                            route: $viewModel.routes,
                            mapItem: mapItem
                        )
                    }
                    .tag(mapItem)
                }

                UserAnnotation()

                ForEach(viewModel.routes, id: \.self) { element in
            
                    MapPolyline(element.polyline)
                        .stroke(Gradient(colors: [.red, .indigo]), style: strokeStyle)
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
                currentPitch = context.camera.pitch
                currentDistance = context.camera.distance
                locationManager.visibleRegion = context.region
            }
            .onChange(of: viewModel.selectedMapItem) {
                if let selectedMapItem = viewModel.selectedMapItem {
                    Task { @MainActor in

                        let mapCamera = createCamera(with: selectedMapItem.coordinate, pitch: currentPitch, distance: currentDistance)

                        withAnimation {
                            location.position = .camera(mapCamera)
                        } completion: {
                            updateScene(with: selectedMapItem)
                        }
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
            .overlay(alignment: .topTrailing) {
                if viewModel.routes.first != nil {
                    DirectionControlsView()
                }
            }
            .onChange(of: viewModel.transportType) {
                if viewModel.routes.first != nil {
                    getDirections()
                }
            }
            .mapStyle(mapStyle)
        }
        .mapScope(mapScope)
    }
}

#Preview {
    let locationManager = LocationManager()
    let viewModel = SearchResultsViewModel(locationManager: locationManager)

    MapDetail()
        .environment(locationManager)
        .environment(viewModel)
}
