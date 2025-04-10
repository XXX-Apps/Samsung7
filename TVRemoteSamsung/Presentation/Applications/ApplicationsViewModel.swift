import UIKit
import TVRemoteControl

// MARK: - View Model

final class TVApplicationsViewModel {
    
    // MARK: - Dependencies
    
    private let appLauncher = TVAppManager()
    private let connectionService = SamsungTVConnectionService.shared
    
    // MARK: - Properties
    
    private(set) var availableApps: [TVApp] = TVApp.allApps()
    
    
    // MARK: - Public Methods
    
    func launchApplication(_ app: TVApp) {
        
        if let ipAddress = SamsungTVConnectionService.shared.connectedDevice?.ipAddress {
            Task {
                try await appLauncher.launch(tvApp: app, tvIPAddress: ipAddress)
            }
        }
    }
}

// MARK: - Error Handling

extension TVApplicationsViewModel {
    enum ApplicationError: Error {
        case deviceNotConnected
    }
}

// MARK: - TVApp Extension

extension TVApp {
    var iconImage: UIImage? {
        let appIcons: [String: String] = [
            "ESPN": "espn",
            "Hulu": "hulu",
            "Max": "max",
            "Netflix": "netflix",
            "Paramount +": "paramount",
            "Pluto TV": "pluto",
            "Prime Video": "prime",
            "Spotify": "spotify",
            "YouTube": "youtube"
        ]
        
        return appIcons[name].flatMap { UIImage(named: $0) }
    }
}
