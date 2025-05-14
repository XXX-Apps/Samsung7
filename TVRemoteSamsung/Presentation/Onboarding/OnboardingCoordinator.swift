import UIKit
import PremiumManager
import SafariServices
import Utilities

// MARK: - View Model

struct FooterButtonConfig {
    let title: String
    let action: Selector
}

struct OnboardingViewModel {
    let backgroundImage: UIImage?
    let titleText: String
    let descriptionText: String
    let needRating: Bool
}

// MARK: - Onboarding Module

protocol OnboardingBusinessLogic {
    func proceedToNextStep()
    func showPrivacyPolicy()
    func showTermsOfService()
    func restorePurchases()
    func completeOnboarding()
}

// Interactor Implementation
final class OnboardingInteractor: @preconcurrency OnboardingBusinessLogic {
    
    private weak var coordinator: OnboardingCoordinator?
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
    }
    
    func proceedToNextStep() {
        coordinator?.routeToNextScreen()
    }
    
    func showPrivacyPolicy() {
        coordinator?.showWebPage(url: Config.privacy)
    }
    
    func showTermsOfService() {
        coordinator?.showWebPage(url: Config.terms)
    }
    
    @MainActor func restorePurchases() {
        PremiumManager.shared.restorePurchases()
    }
    
    func completeOnboarding() {
        coordinator?.finishOnboarding()
    }
}

final class OnboardingCoordinator {
    
    private let window: UIWindow?
    private var currentStep = 0
    
    private lazy var steps: [OnboardingViewModel] = [
        OnboardingViewModel(
            backgroundImage: UIImage(named: "onboarding_0"),
            titleText: "Convenient TV Remote".localized,
            descriptionText: "Control your TV anytime in a comfortable way".localized,
            needRating: false
        ),
        OnboardingViewModel(
            backgroundImage: UIImage(named: "onboarding_1"),
            titleText: "Multi-functional".localized,
            descriptionText: "Switch keyboards as you wish to get maximum functionality".localized,
            needRating: false
        ),
        OnboardingViewModel(
            backgroundImage: UIImage(named: "onboarding_2"),
            titleText: "Your thoughts matters".localized,
            descriptionText: "Your input helps in improving your in-app experience".localized,
            needRating: true
        ),
        OnboardingViewModel(
            backgroundImage: UIImage(named: "onboarding_3"),
            titleText: "All platforms in one".localized,
            descriptionText: "Watch all your favorite streaming platforms easily in one place".localized,
            needRating: false
        )
    ]
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        showCurrentStep()
    }
    
    private func showCurrentStep() {
        guard currentStep < steps.count else {
            showPaywall()
            return
        }
        
        let viewModel = steps[currentStep]
        let viewController = OnboardingViewController(
            viewModel: viewModel,
            interactor: OnboardingInteractor(coordinator: self),
            dismissOnClose: false
        )
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        currentStep += 1
    }
    
    // MARK: - Routing
    
    func routeToNextScreen() {
        showCurrentStep()
    }
    
    func showWebPage(url: String) {
        guard let url = URL(string: url) else { return }
        let safariVC = SFSafariViewController(url: url)
        window?.rootViewController?.present(safariVC, animated: true)
    }
    
    func finishOnboarding() {
        window?.rootViewController = TabBarConfigurator.main()
        window?.makeKeyAndVisible()
    }
    
    private func showPaywall() {
        let paywall = PaywallViewController.init(
            dismissOnClose: false,
            interactor: OnboardingInteractor(coordinator: self)
        )
        window?.rootViewController = paywall
        window?.makeKeyAndVisible()
    }
}
