import UIKit
import Utilities

struct OnboardingModel {
    let image: UIImage?
    let title: String
    let subtitle: String
    let rating: Bool
}

class OnboardingCoordinator {
    
    private let window: UIWindow
    private var currentIndex = 0
    private let models: [OnboardingModel] = [
        OnboardingModel(
            image: UIImage(named: "onboarding_0"),
            title: "Convenient TV Remote".localized,
            subtitle: "Control your TV anytime in a comfortable way".localized,
            rating: false
        ),
        OnboardingModel(
            image: UIImage(named: "onboarding_1"),
            title: "Multi-functional".localized,
            subtitle: "Switch keyboards as you wish to get maximum functionality".localized,
            rating: true
        ),
        OnboardingModel(
            image: UIImage(named: "onboarding_2"),
            title: "Your thoughts matters".localized,
            subtitle: "Your input helps in improving your in-app experience".localized,
            rating: false
        ),
        OnboardingModel(
            image: UIImage(named: "onboarding_3"),
            title: "All platforms in one".localized,
            subtitle: "Watch all your favorite streaming platforms easily in one place".localized,
            rating: false
        )
    ]
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showNextViewController()
    }
    
    private func showNextViewController() {
        guard currentIndex < models.count else {
            transitionToPaywall()
            return
        }
        
        let model = models[currentIndex]
        let viewController = OnboardingController(model: model, coordinator: self)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        currentIndex += 1
    }
    
    func goToNextScreen() {
        showNextViewController()
    }
    
    private func transitionToPaywall() {
        let vc = Paywall()
        vc.isFromOnboarding = true
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
