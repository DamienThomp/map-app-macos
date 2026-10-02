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
    var isPopoverPresented = false
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
        isPopoverPresented = false
        sceneErrorMessage = nil
    }

    func handleSelectionChange(to place: PlaceAnnotation?) {
        guard let place else {
            deselect()
            return
        }

        guard selectedPlace?.id != place.id else { return }

        select(place)
    }

    func select(_ place: PlaceAnnotation) {
        sceneTask?.cancel()
        lookAroundScene = nil
        sceneErrorMessage = nil
        selectedPlace = place
        isPopoverPresented = false

        directionsResetting?.resetDirections()

        mapStore.focus(on: place.coordinate) {
            guard self.selectedPlace?.id == place.id else { return }
            self.isPopoverPresented = true
            self.loadLookAround(for: place)
        }
    }

    func presentPopover() {
        guard selectedPlace != nil else { return }
        isPopoverPresented = true
    }

    func dismissPopover() {
        isPopoverPresented = false
    }

    func hidePopoverForDirections() {
        isPopoverPresented = false
    }

    func loadLookAround(for place: PlaceAnnotation) {
        sceneTask?.cancel()
        sceneErrorMessage = nil
        sceneTask = Task {
            do {
                try await fetchScene(for: place)
                try Task.checkCancellation()
                guard selectedPlace?.id == place.id else { return }
            } catch is CancellationError {
                return
            } catch {
                guard selectedPlace?.id == place.id else { return }
                sceneErrorMessage = error.localizedDescription
            }
        }
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
