import Foundation

final class MonumentDataService {
    static let shared = MonumentDataService()
    
    private init() {}
    
    func loadMonuments() -> [Monument] {
        guard let url = Bundle.main.url(forResource: "monuments", withExtension: "json") else {
            print("monuments.json introuvable")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let monuments = try JSONDecoder().decode([Monument].self, from: data)
            return monuments
        } catch {
            print("Erreur décodage monuments: \(error)")
            return []
        }
    }
    
    func monument(withId id: UUID) -> Monument? {
        loadMonuments().first { $0.id == id }
    }
    
    func monuments(inArrondissement arrondissement: Int) -> [Monument] {
        loadMonuments().filter { $0.arrondissement == arrondissement }
    }
}
