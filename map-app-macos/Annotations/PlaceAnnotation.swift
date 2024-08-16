//
//  PlaceAnnotation.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import Foundation
import SwiftUI
import MapKit
import Contacts

class PlaceAnnotation: NSObject, MKAnnotation, Identifiable {
    
    let id = UUID()

    private var mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }

    var title: String? {
        mapItem.name
    }

    var address: String {
        guard let postalAddress = mapItem.placemark.postalAddress else {
            return ""
        }

        return "\(postalAddress.street), \(postalAddress.city), \(postalAddress.state), \(postalAddress.postalCode)"
    }

    var location: CLLocation? {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var coordinate: CLLocationCoordinate2D {
        mapItem.placemark.coordinate
    }

    var placeMark: MKPlacemark {
        mapItem.placemark
    }

    var url: URL? {
        mapItem.url
    }

    var phoneNumber: String? {
        mapItem.phoneNumber
    }

    var pointOfInterestCategory: MKPointOfInterestCategory? {

        guard let category = mapItem.pointOfInterestCategory else { return nil }

        return category
    }

    var pointOfInterestIcon: String {

        let (icon, _ ) = AnnotationHelper.getIconforAnotation(pointOfInterestCategory)

        return icon
    }

    var pointOfInterestColor: Color {
        
        let (_, color) = AnnotationHelper.getIconforAnotation(pointOfInterestCategory)

        return color
    }

    func getDistance(userLocation: CLLocation?) -> Measurement<UnitLength>? {

        guard let placeLocation = mapItem.placemark.location,
              let userLocation = userLocation else { return nil }

        return Measurement(value: userLocation.distance(from: placeLocation), unit: .meters)
    }
}
