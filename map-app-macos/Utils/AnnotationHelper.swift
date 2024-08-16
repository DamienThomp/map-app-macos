//
//  AnnotationHelper.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-08-15.
//

import Foundation
import MapKit
import SwiftUI

enum AnnotationHelper {

    static func getIconforAnotation( _ placeOfInterest: MKPointOfInterestCategory?) -> (String, Color) {

        switch placeOfInterest {
        case .airport:
            return ("airplane.circle.fill", .teal)
        case .bakery:
            return ("bag.circle.fill", .orange)
        case .cafe:
            return ("fork.knife.circle.fill", .pink)
        case .foodMarket:
            return ("cart.circle.fill", .cyan)
        case .bank:
            return ("dollarsign.circle.fill", .green)
        case .gasStation:
            return ("fuelpump.circle.fill", .brown)
        case .hotel:
            return ("building.2.crop.circle.fill", .teal)
        case .restaurant:
            return ("fork.knife.circle.fill", .red)
        case .store:
            return ("storefront.circle.fill", .orange)
        case .publicTransport:
            return ("tram.circle.fill", .teal)
        case .park:
            return ("tree.circle.fill", .green)
        default:
            return ("mappin.circle.fill", .pink)
        }
    }
}
