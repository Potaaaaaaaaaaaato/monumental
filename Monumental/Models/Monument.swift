import Foundation
import CoreLocation

struct TransportLine: Codable, Hashable {
    let station: String
    let lignes: [String]
    let latitude: Double?
    let longitude: Double?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct TransportInfo: Codable, Hashable {
    let metro: [TransportLine]?
    let rer: [TransportLine]?
    let bus: [String]?
    let tramway: [TransportLine]?
    let noctilien: [String]?
}

struct Monument: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let nom: String
    let description: String
    let latitude: Double
    let longitude: Double
    let arrondissement: Int
    let dateConstruction: String
    let architecte: String
    let contexteHistorique: String
    let categories: [String]
    let transports: TransportInfo?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension Monument {
    var localizedName: String {
        NSLocalizedString(nom, tableName: "MonumentNames", bundle: .main, value: nom, comment: "")
    }
    
    static let preview = Monument(
        id: UUID(),
        nom: "Tour Eiffel",
        description: "La tour Eiffel est une tour de fer puddlé de 330 mètres de hauteur située à Paris.",
        latitude: 48.8584,
        longitude: 2.2945,
        arrondissement: 7,
        dateConstruction: "1887-1889",
        architecte: "Gustave Eiffel",
        contexteHistorique: "Construite pour l'Exposition universelle de 1889, centenaire de la Révolution française.",
        categories: ["Tour", "Monument historique", "Patrimoine mondial"],
        transports: TransportInfo(
            metro: [
                TransportLine(station: "Bir-Hakeim", lignes: ["6"], latitude: 48.8539, longitude: 2.2899),
                TransportLine(station: "Trocadéro", lignes: ["6", "9"], latitude: 48.8629, longitude: 2.2878)
            ],
            rer: [
                TransportLine(station: "Champ de Mars - Tour Eiffel", lignes: ["C"], latitude: 48.8557, longitude: 2.2899)
            ],
            bus: ["42", "69", "72", "82", "87"],
            tramway: nil,
            noctilien: ["N01", "N02"]
        )
    )
}
