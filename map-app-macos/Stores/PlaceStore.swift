//
//  PlaceStore.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import Foundation
import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
final class PlaceStore: PlaceSelecting, PlaceProviding {

    var selectedPlace: PlaceAnnotation?
    var lookAroundScene: MKLookAroundScene?
    var markerPresentation: MarkerPresentation = .none
    var sceneErrorMessage: String?

    @ObservationIgnored
    weak var directionsResetting: (any DirectionsResetting)?

    private let mapStore: MapStore
    private let sceneCache = NSCache<NSString, MKLookAroundScene>()
    private var sceneTask: Task<Void, Never>?

    init(mapStore: MapStore) {
        self.mapStore = mapStore
    }

    var selectionBinding: Binding<PlaceAnnotation?> {
        Binding(
            get: { self.selectedPlace },
            set: { self.handleSelectionChange(to: $0) }
        )
    }

    func clearSelection() {
        deselect()
    }

    func deselect() {
        sceneTask?.cancel()
        selectedPlace = nil
        lookAroundScene = nil
        markerPresentation = .none
        sceneErrorMessage = nil
    }

    func handleSelectionChange(to place: PlaceAnnotation?) {
        guard let place else {
            deselect()
            return
        }

        let isNewSelection = selectedPlace?.id != place.id

        if isNewSelection {
            lookAroundScene = nil
            sceneTask?.cancel()
            sceneErrorMessage = nil
        }

        selectedPlace = place
        markerPresentation = .none

        directionsResetting?.resetDirections()

        mapStore.focus(on: place.coordinate) {
            self.loadLookAround(for: place)
        }
    }

    func loadLookAround(for place: PlaceAnnotation) {
        sceneTask?.cancel()
        sceneErrorMessage = nil
        sceneTask = Task {
            do {
                try await fetchScene(for: place)
                try Task.checkCancellation()
                guard selectedPlace?.id == place.id else { return }
                markerPresentation = .lookAround
            } catch is CancellationError {
                return
            } catch {
                guard selectedPlace?.id == place.id else { return }
                sceneErrorMessage = error.localizedDescription
                markerPresentation = .none
            }
        }
    }

    func showLookAround() {
        guard selectedPlace != nil else { return }
        markerPresentation = .lookAround
    }

    func dismissMarkerPopover() {
        if markerPresentation == .lookAround {
            markerPresentation = .none
        }
    }

    func setMarkerPresentation(_ presentation: MarkerPresentation) {
        markerPresentation = presentation
    }

    private func fetchScene(for place: PlaceAnnotation) async throws {
        let coordinateKey = NSString(
            string: "\(place.coordinate.latitude),\(place.coordinate.longitude)"
        )

        if let cachedScene = sceneCache.object(forKey: coordinateKey) {
            lookAroundScene = cachedScene
            return
        }

        let request = MKLookAroundSceneRequest(coordinate: place.coordinate)
        let scene = try await request.scene

        try Task.checkCancellation()

        if let scene {
            sceneCache.setObject(scene, forKey: coordinateKey)
            lookAroundScene = scene
        }
    }
}
