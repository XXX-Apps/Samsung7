
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
    
    private let closeButton = UIButton().apply {
        $0.setImage(UIImage(named: "closeGray"), for: .normal)
    }
    
    override func prepareView() {
        super.prepareView()
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeFlow), for: .touchUpInside)
        
        backgroundImageView.image = UIImage(named: "paywall")
        headerLabel.text = "Get all Unlimited".localized
        
        if let product = PremiumManager.shared.products.value.first, let price = product.priceNumber, let duration = product.duration?.rawValue.localized {
            let priceText = "\(product.currency)\(String(format: "%.2f", price))/\(duration)"
            descriptionLabel.text = String(format: "Unlimited connections, all the tools and much more at".localized, priceText)
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(21)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(20)
        }
    }
    
    override func didTapActionButton() {
        super.didTapActionButton()
        PremiumManager.shared.purchase(product: PremiumManager.shared.products.value.first)
    }
    
    @objc private func closeFlow() {
        if dismissOnClose {
            replaceRootViewController(with: TabBarConfigurator.main())
        } else {
            dismiss()
        }
    }
}
