//
//  LoadState.swift
//  map-app-macos
//
//  Created by Damien L Thompson on 2026-09-22.
//

import Foundation

enum LoadState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(String)
}

enum MarkerPresentation: Equatable {
    case none
    case lookAround
    case directions
}
