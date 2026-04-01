import SwiftUI

enum TransportColors {
    static func metro(_ ligne: String) -> Color {
        switch ligne {
        case "1": return Color(red: 255/255, green: 206/255, blue: 0/255)     // Jaune
        case "2": return Color(red: 0/255, green: 100/255, blue: 180/255)     // Bleu
        case "3": return Color(red: 155/255, green: 152/255, blue: 45/255)    // Olive
        case "3bis": return Color(red: 130/255, green: 190/255, blue: 220/255) // Bleu clair
        case "4": return Color(red: 190/255, green: 60/255, blue: 145/255)    // Magenta
        case "5": return Color(red: 245/255, green: 130/255, blue: 50/255)    // Orange
        case "6": return Color(red: 130/255, green: 195/255, blue: 145/255)   // Vert clair
        case "7": return Color(red: 240/255, green: 165/255, blue: 175/255)   // Rose
        case "7bis": return Color(red: 130/255, green: 195/255, blue: 145/255) // Vert clair
        case "8": return Color(red: 200/255, green: 160/255, blue: 200/255)   // Lilas
        case "9": return Color(red: 205/255, green: 190/255, blue: 50/255)    // Jaune-vert
        case "10": return Color(red: 220/255, green: 165/255, blue: 75/255)   // Ocre
        case "11": return Color(red: 140/255, green: 100/255, blue: 60/255)   // Marron
        case "12": return Color(red: 0/255, green: 130/255, blue: 80/255)     // Vert foncé
        case "13": return Color(red: 130/255, green: 190/255, blue: 220/255)  // Bleu clair
        case "14": return Color(red: 100/255, green: 50/255, blue: 145/255)   // Violet
        default: return .blue
        }
    }
    
    static func rer(_ ligne: String) -> Color {
        switch ligne.uppercased() {
        case "A": return Color(red: 235/255, green: 50/255, blue: 50/255)     // Rouge
        case "B": return Color(red: 75/255, green: 140/255, blue: 210/255)    // Bleu
        case "C": return Color(red: 255/255, green: 215/255, blue: 0/255)     // Jaune
        case "D": return Color(red: 0/255, green: 160/255, blue: 95/255)      // Vert
        case "E": return Color(red: 190/255, green: 130/255, blue: 180/255)   // Violet/Rose
        default: return .purple
        }
    }
}
