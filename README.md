# Map App

A native SwiftUI map explorer for macOS and iPad. Search for points of interest, browse results in a sidebar, inspect places with Look Around, and get turn-by-turn routes from your current location.

Built with Swift 6 and MapKit, targeting macOS 15+ and iPadOS 17.6+. The app uses a protocol-oriented store architecture with structured concurrency and no third-party networking dependencies.

## Features

### Search

- **Local search** — Search points of interest from the sidebar. Queries are debounced and scoped to the map’s visible region.
- **Result list** — Results appear in the sidebar with POI icons, titles, and distance from your location when available.
- **Selection sync** — Selecting a row or map marker focuses the map and loads place details.

### Map

- **Markers** — Search results render as category-colored annotations on the map.
- **User location** — Live location updates via Core Location; the map centers on your position when authorization is granted.
- **Camera controls** — Zoom stepper, pitch slider, and compass (macOS). Toolbar controls for user location, 2D/3D pitch toggle, and map style.
- **Map styles** — Switch between Standard (flat, no traffic) and Hybrid (realistic elevation, traffic).

### Place details

- **Marker popover** — Tap a marker to select it; tap again to open a popover with title, phone, and website links.
- **Look Around** — Street-level preview loads asynchronously for the selected coordinate, with in-memory caching and error messaging when unavailable.
- **Get directions** — Request a route from your current location to the selected place.

### Directions

- **Route overlay** — Active routes render as gradient polylines on the map.
- **Transport modes** — Switch between driving, walking, and transit. Walking requests alternate routes.
- **Controls overlay** — Dismiss directions or change transport type from a floating panel while a route is active.
- **Selection coordination** — Starting directions hides the popover; dismissing directions restores it when a place is still selected.

## Architecture

Map App follows a protocol-oriented MV pattern:

| Layer | Description |
| ----- | ----------- |
| **Views** | SwiftUI views bind directly to `@Observable` stores via `@Environment` |
| **Stores** | `MapStore`, `SearchStore`, `PlaceStore`, `DirectionsStore`, `LocationManager` — async work via structured concurrency |
| **Async UI** | Screen-level loading and error states via `LoadState<T>` |
| **Composition** | `AppDependencies.make()` wires stores at the app root and installs them into the environment |
| **Cross-store coordination** | Weak protocol references (`PlaceSelecting`, `DirectionsResetting`, `UserLocationObserving`, `PlaceProviding`) avoid tight coupling between stores |
| **Caching** | In-memory `NSCache` for local search responses and Look Around scenes |

Store responsibilities:

- **`MapStore`** — Camera position, visible region, map style, and focus animations (skips redundant camera moves when the target is already near center).
- **`SearchStore`** — Debounced `MKLocalSearch` scoped to the visible map region.
- **`PlaceStore`** — Selection state, popover presentation, and Look Around scene loading.
- **`DirectionsStore`** — Route calculation via `MKDirections` with transport-type switching.
- **`LocationManager`** — Authorization handling and live location updates via `CLLocationUpdate`.

Key Apple frameworks:

- **MapKit** — Map, annotations, local search, directions, Look Around
- **Core Location** — User location and authorization

## Requirements

- Xcode with macOS 15 SDK (and iPadOS 17.6 SDK for iPad builds)
- Mac or iPad simulator/device with location services enabled
- No API keys or external accounts required

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/DamienThomp/map-app-macos.git
   cd map-app-macos
   ```

2. **Open in Xcode**

   Open `map-app-macos.xcodeproj`. Xcode resolves the [SFSymbolsMacro](https://github.com/lukepistrol/SFSymbolsMacro) Swift Package dependency automatically.

3. **Build and run**

   Select **My Mac** or an iPad simulator and run (⌘R). Grant location access when prompted — directions and distance labels require it.

## Project structure

```
map-app-macos/
├── Annotations/      # PlaceAnnotation wrapper around MKMapItem
├── Models/           # LoadState and shared model types
├── Screens/          # HomeScreen (NavigationSplitView shell)
├── Stores/           # Observable stores, protocols, AppDependencies
├── Utils/            # Annotation icons, SFSymbolsMacro helpers
└── Views/            # Map, sidebar, search, markers, directions UI
```

## Permissions

The app requests:

- **Location (When In Use)** — Show your position on the map, compute distances, and calculate directions

Location usage descriptions are configured in the target’s Info.plist settings.

## Roadmap

- [ ] Add locations to a favourites list
- [ ] Settings for units (metric or imperial)
- [ ] More details and actions in marker popovers

## Screenshot

<img width="1501" alt="Screenshot 2024-08-15 at 8 57 54 PM" src="https://github.com/user-attachments/assets/140ef71b-aac0-4a9e-a6f5-5faf493ba4c0">
