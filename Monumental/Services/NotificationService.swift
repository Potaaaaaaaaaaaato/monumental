import Foundation
import Combine
import UserNotifications

final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    private var notifiedMonumentIds: Set<UUID> = []
    private var cooldownTimestamps: [UUID: Date] = [:]
    private let cooldownDuration: TimeInterval = 3600
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { isAuthorized = granted }
            return granted
        } catch {
            print("Erreur autorisation notifications: \(error)")
            return false
        }
    }
    
    func sendMonumentNotification(for monument: Monument) {
        guard isAuthorized else { return }
        guard canNotify(for: monument.id) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.monument.nearby.title")
        content.body = String(
            format: NSLocalizedString("notification.monument.nearby.body", comment: ""),
            monument.localizedName
        )
        content.sound = .default
        content.userInfo = ["monumentId": monument.id.uuidString]
        
        let request = UNNotificationRequest(
            identifier: monument.id.uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if error == nil {
                self?.markAsNotified(monument.id)
            }
        }
    }
    
    private func canNotify(for monumentId: UUID) -> Bool {
        if let lastNotified = cooldownTimestamps[monumentId] {
            return Date().timeIntervalSince(lastNotified) >= cooldownDuration
        }
        return true
    }
    
    private func markAsNotified(_ monumentId: UUID) {
        notifiedMonumentIds.insert(monumentId)
        cooldownTimestamps[monumentId] = Date()
    }
    
    func resetCooldown(for monumentId: UUID) {
        cooldownTimestamps.removeValue(forKey: monumentId)
    }
    
    func resetAllCooldowns() {
        cooldownTimestamps.removeAll()
        notifiedMonumentIds.removeAll()
    }
}
