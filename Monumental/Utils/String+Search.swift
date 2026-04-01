import Foundation

extension String {
    var normalizedForSearch: String {
        let folded = folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let normalizedApostrophes = folded
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
        return normalizedApostrophes
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
            .lowercased()
    }
}
