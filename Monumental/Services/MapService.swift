import Foundation
import MapKit
import CoreLocation

final class MapService {
    static let shared = MapService()
    
    private init() {}
    
    func createAnnotations(for monuments: [Monument]) -> [MonumentAnnotation] {
        monuments.map { MonumentAnnotation(monument: $0) }
    }
    
    func region(for monuments: [Monument], padding: Double = 0.01) -> MKCoordinateRegion {
        guard !monuments.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        
        let latitudes = monuments.map { $0.latitude }
        let longitudes = monuments.map { $0.longitude }
        
        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (latitudes.max()! - latitudes.min()!) + padding,
            longitudeDelta: (longitudes.max()! - longitudes.min()!) + padding
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func regionForParis() -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    }
    
    func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: Monument,
        transportType: MKDirectionsTransportType = .walking
    ) async -> MKRoute? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = transportType
        
        do {
            let response = try await MKDirections(request: request).calculate()
            return response.routes.first
        } catch {
            print("Erreur calcul itinéraire: \(error)")
            return nil
        }
    }
    
    func openInMaps(monument: Monument) {
        let placemark = MKPlacemark(coordinate: monument.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = monument.localizedName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

final class MonumentAnnotation: NSObject, MKAnnotation, Identifiable {
    let id: UUID
    let monument: Monument
    
    var coordinate: CLLocationCoordinate2D { monument.coordinate }
    var title: String? { monument.localizedName }
    var subtitle: String? {
        LocalizationFormatter.arrondissement(monument.arrondissement)
    }
    
    init(monument: Monument) {
        self.id = monument.id
        self.monument = monument
    }
}

enum StationType: String {
    case metro
    case rer
    case tramway
}

final class StationAnnotation: NSObject, Identifiable {
    let id = UUID()
    let station: String
    let lignes: [String]
    let coordinate: CLLocationCoordinate2D
    let type: StationType
    
    init(station: String, lignes: [String], coordinate: CLLocationCoordinate2D, type: StationType) {
        self.station = station
        self.lignes = lignes
        self.coordinate = coordinate
        self.type = type
    }
}

extension MapService {
    func createStationAnnotations(for monument: Monument) -> [StationAnnotation] {
        var annotations: [StationAnnotation] = []
        
        guard let transports = monument.transports else { return annotations }
        
        if let metros = transports.metro {
            for metro in metros {
                if let coordinate = metro.coordinate {
                    annotations.append(StationAnnotation(
                        station: metro.station,
                        lignes: metro.lignes,
                        coordinate: coordinate,
                        type: .metro
                    ))
                }
            }
        }
        
        if let rers = transports.rer {
            for rer in rers {
                if let coordinate = rer.coordinate {
                    annotations.append(StationAnnotation(
                        station: rer.station,
                        lignes: rer.lignes,
                        coordinate: coordinate,
                        type: .rer
                    ))
                }
            }
        }
        
        if let tramways = transports.tramway {
            for tramway in tramways {
                if let coordinate = tramway.coordinate {
                    annotations.append(StationAnnotation(
                        station: tramway.station,
                        lignes: tramway.lignes,
                        coordinate: coordinate,
                        type: .tramway
                    ))
                }
            }
        }
        
        return annotations
    }
}
