import Foundation
import StorageManager
import TVRemoteControl

final class LocalDataBase {

    // MARK: - Properties
    
    static let shared = LocalDataBase()

    private let storageManager: StorageManager = .shared

    // MARK: - Public Properties

    var isOnboardingShown: Bool {
        get {
            storageManager.get(forKey: Constants.onboardingShownKey, defaultValue: false)
        }
        set {
            storageManager.set(newValue, forKey: Constants.onboardingShownKey)
        }
    }

    var isFeedbackShown: Bool {
        get {
            storageManager.get(forKey: Constants.feedbackShownKey, defaultValue: false)
        }
        set {
            storageManager.set(newValue, forKey: Constants.feedbackShownKey)
        }
    }
    
    var userActionCounter: Int {
        get {
            storageManager.get(forKey: Constants.userActionCounter, defaultValue: 0)
        }
        set {
            storageManager.set(newValue, forKey: Constants.userActionCounter)
        }
    }
    
    
    private let deviceKey = "ConnectedTVDevice"
    
    func saveConnectedDevice(_ device: SamsungTVModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(device) {
            UserDefaults.standard.set(encoded, forKey: deviceKey)
        }
    }
    
    func restoreConnectedDevice() -> SamsungTVModel? {
        if let savedDevice = UserDefaults.standard.data(forKey: deviceKey) {
            let decoder = JSONDecoder()
            if let device = try? decoder.decode(SamsungTVModel.self, from: savedDevice) {
                return device
            }
        }
        return nil
    }
    
    private func clearConnectedDevice() {
        UserDefaults.standard.removeObject(forKey: deviceKey)
    }

    // MARK: - Constants

    private enum Constants {
        static let onboardingShownKey = "onboarding_shown"
        static let feedbackShownKey = "feedback_shown"
        static let userActionCounter = "user_action_counter"
    }
}
