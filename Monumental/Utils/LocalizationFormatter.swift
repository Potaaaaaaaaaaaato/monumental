import Foundation

enum LocalizationFormatter {
    static func arrondissement(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formatter.locale = Locale.current
        let ordinal = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        let template = String(localized: "common.arrondissement.template")
        return String(format: template, ordinal)
    }
}
