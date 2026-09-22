//
//  LoadState.swift
//  map-app-macos
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
