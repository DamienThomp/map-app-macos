//
//  PlaceAnnotation.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import Foundation
import SwiftUI
import MapKit

struct PlaceAnnotation: Identifiable, Hashable {

    let id: UUID
    let mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.id = UUID()
        self.mapItem = mapItem
    }

    var title: String? {
        mapItem.name
    }

    var address: String {
        if #available(macOS 26.0, iOS 18.0, *) {
            return mapItem.address?.fullAddress ?? ""
        }
        return mapItem.placemark.title ?? ""
    }

    var location: CLLocation? {
        if #available(macOS 26.0, iOS 18.0, *) {
            return mapItem.location
        }
        return mapItem.placemark.location
    }

    var coordinate: CLLocationCoordinate2D {
        if #available(macOS 26.0, iOS 18.0, *) {
            return mapItem.location.coordinate
        }
        return mapItem.placemark.coordinate
    }

    var url: URL? {
        mapItem.url
    }

    var phoneNumber: String? {
        mapItem.phoneNumber
    }

    var pointOfInterestCategory: MKPointOfInterestCategory? {
        mapItem.pointOfInterestCategory
    }

    var pointOfInterestIcon: String {
        let (icon, _) = AnnotationHelper.getIconForAnnotation(pointOfInterestCategory)
        return icon
    }

    var pointOfInterestColor: Color {
        let (_, color) = AnnotationHelper.getIconForAnnotation(pointOfInterestCategory)
        return color
    }

    func getDistance(userLocation: CLLocation?) -> Measurement<UnitLength>? {
        guard let placeLocation = location,
              let userLocation else { return nil }

        return Measurement(value: userLocation.distance(from: placeLocation), unit: .meters)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PlaceAnnotation, rhs: PlaceAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}
