import Foundation
import StorageManager

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

    // MARK: - Constants

    private enum Constants {
        static let onboardingShownKey = "onboarding_shown"
        static let feedbackShownKey = "feedback_shown"
        static let userActionCounter = "user_action_counter"
    }
}
