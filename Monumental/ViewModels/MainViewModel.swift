import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var monuments: [Monument] = []
    @Published var isLocationAuthorized = false
    @Published var isNotificationAuthorized = false
    @Published var isLoading = true
    
    private let monumentDataService = MonumentDataService.shared
    private let locationService = LocationService.shared
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadMonuments()
    }
    
    private func setupBindings() {
        locationService.$isAuthorized
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLocationAuthorized)
        
        notificationService.$isAuthorized
            .receive(on: DispatchQueue.main)
            .assign(to: &$isNotificationAuthorized)
    }
    
    func loadMonuments() {
        monuments = monumentDataService.loadMonuments()
        isLoading = false
    }
    
    func requestPermissions() {
        locationService.requestAuthorization()
        Task {
            _ = await notificationService.requestAuthorization()
        }
    }
}
