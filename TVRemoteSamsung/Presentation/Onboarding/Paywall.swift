
import UIKit
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import PremiumManager
import Utilities

// MARK: - Paywall
final class PaywallViewController: OnboardingViewController {
    
    init(dismissOnClose: Bool = true, viewModel: OnboardingViewModel? = nil, interactor: (any OnboardingBusinessLogic)? = nil) {
        super.init(viewModel: viewModel, interactor: interactor, dismissOnClose: dismissOnClose)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareButtons() {
        [
            FooterButtonConfig.init(title: "Privacy".localized, action: #selector(OnboardingViewController.didTapPrivacyButton)),
            FooterButtonConfig.init(title: "Restore".localized, action: #selector(OnboardingViewController.didTapRestoreButton)),
            FooterButtonConfig.init(title: "Terms".localized, action: #selector(OnboardingViewController.didTapTermsButton)),
            FooterButtonConfig.init(title: "Not now".localized, action: #selector(closeFlow)),
        ].forEach { buttonConfig in
            let button = UIButton(type: .system)
            button.setTitle(buttonConfig.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(
                ofSize: Locale.current.isEnglish ? 13 : 10,
                weight: .regular
            )
            button.setTitleColor(UIColor(red: 0.4, green: 0.48, blue: 0.7, alpha: 1), for: .normal)
            button.addTarget(self, action: buttonConfig.action, for: .touchUpInside)
            footerButtonsStack.addArrangedSubview(button)
        }
    }
    
    override func prepareView() {
        super.prepareView()
        
        backgroundImageView.image = UIImage(named: "paywall")
        headerLabel.text = "Get all Unlimited".localized
        
        if let product = PremiumManager.shared.products.value.first, let price = product.priceNumber, let duration = product.duration?.rawValue.localized {
            let priceText = "\(product.currency)\(String(format: "%.2f", price))/\(duration)"
            descriptionLabel.text = String(format: "Unlimited connections, all the tools and much more at".localized, priceText)
        }
    }
    
    override func didTapActionButton() {
        super.didTapActionButton()
        PremiumManager.shared.purchase(product: PremiumManager.shared.products.value.first)
    }
    
    @objc private func closeFlow() {
        if dismissOnClose {
            dismiss()
        } else {
            replaceRootViewController(with: TabBarConfigurator.main())
        }
    }
}
