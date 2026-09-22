//
//  MapMacosApp.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2024-07-22.
//

import SwiftUI

@main
struct MapMacosApp: App {

    private let dependencies = AppDependencies.make()

    var body: some Scene {
        WindowGroup {
            dependencies.installEnvironments(on: HomeScreen())
        }
    }
}
