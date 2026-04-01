import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var monuments: [Monument] = []
    @Published var selectedMonument: Monument?
    @Published var annotations: [MonumentAnnotation] = []
    @Published var stationAnnotations: [StationAnnotation] = []
    
    private let mapService = MapService.shared
    private let monumentDataService = MonumentDataService.shared
    
    init() {
        region = mapService.regionForParis()
        loadMonuments()
    }
    
    func loadMonuments() {
        monuments = monumentDataService.loadMonuments()
        annotations = mapService.createAnnotations(for: monuments)
    }
    
    func selectMonument(_ monument: Monument) {
        selectedMonument = monument
        stationAnnotations = mapService.createStationAnnotations(for: monument)
        centerOn(monument)
    }
    
    func deselectMonument() {
        selectedMonument = nil
        stationAnnotations = []
    }
    
    func centerOn(_ monument: Monument) {
        withAnimation {
            region = MKCoordinateRegion(
                center: monument.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func showAllMonuments() {
        deselectMonument()
        region = mapService.region(for: monuments)
    }
    
    func filterByArrondissement(_ arrondissement: Int?) {
        if let arr = arrondissement {
            let filtered = monumentDataService.monuments(inArrondissement: arr)
            annotations = mapService.createAnnotations(for: filtered)
            region = mapService.region(for: filtered)
        } else {
            annotations = mapService.createAnnotations(for: monuments)
            region = mapService.region(for: monuments)
        }
    }
}
