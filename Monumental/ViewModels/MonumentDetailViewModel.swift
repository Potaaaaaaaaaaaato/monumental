import Foundation
import Combine
import MapKit
import CoreLocation

@MainActor
final class MonumentDetailViewModel: ObservableObject {
    @Published var monument: Monument
    @Published var distance: String?
    @Published var route: MKRoute?
    @Published var isLoadingRoute = false
    
    private let mapService = MapService.shared
    private let locationService = LocationService.shared
    
    init(monument: Monument) {
        self.monument = monument
        updateDistance()
    }
    
    func updateDistance() {
        guard let dist = locationService.distance(to: monument) else {
            distance = nil
            return
        }
        
        if dist < 1000 {
            distance = String(format: "%.0f m", dist)
        } else {
            distance = String(format: "%.1f km", dist / 1000)
        }
    }
    
    func calculateRoute() async {
        guard let location = locationService.currentLocation else { return }
        
        isLoadingRoute = true
        route = await mapService.calculateRoute(from: location.coordinate, to: monument)
        isLoadingRoute = false
    }
    
    func openInMaps() {
        mapService.openInMaps(monument: monument)
    }
    
    var formattedCategories: String {
        monument.categories.joined(separator: " • ")
    }
}
