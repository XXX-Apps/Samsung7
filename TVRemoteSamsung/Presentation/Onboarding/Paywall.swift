
import UIKit
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import PremiumManager
import Utilities

private enum Constants {
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
}

class Paywall: OnboardingController {
        
    var isFromOnboarding: Bool = false
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(named: "closeGray"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        
        view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(21)
            make.right.equalToSuperview().inset(20)
            make.height.width.equalTo(20)
        }
        
        imageView.image = UIImage(named: "paywall")
        
        titleLabel.text = "Get all Unlimited".localized

        let product = PremiumManager.shared.products.value.first
        
        if let priceNumber = product?.priceNumber,
           let currency = product?.currency,
           let duration = product?.duration {
            let price = "\(currency)\(String(format: "%.2f", priceNumber))/\(duration.rawValue.localized)"
            
            subtitleLabel.text = String(format: "Unlimited connections, all the tools and much more at".localized, price)
        }
    }
    
    override func bottomButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let product = PremiumManager.shared.products.value.first
        
        PremiumManager.shared.purchase(product: product)
    }
    
    @objc private func handleCloseAction() {
        closeAction()
    }
    
    override func closeAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if isFromOnboarding {
            replaceRootViewController(with: TabBarConfigurator.main())
        } else {
            dismiss()
        }
    }
}
