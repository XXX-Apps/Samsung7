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

class OnboardingViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    // UI Components
    let backgroundImageView = MyImageView().apply {
        $0.aspectFill = true
        $0.verticalAlignment = .top
    }
    
    let headerLabel = UILabel().apply {
        $0.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    let descriptionLabel = UILabel().apply {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 0.4, green: 0.48, blue: 0.7, alpha: 1)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var actionButton: ShadowImageButton = {
        let button = ShadowImageButton()
        button.configure(
            buttonConfig: .init(
                title: "Continue".localized,
                font: .font(
                    weight: .medium,
                    size: 18
                ),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "buttonGradient"),
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "117FF5"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        button.action = { [weak self] in self?.didTapActionButton() }
        return button
    }()
    
    private let footerButtonsStack = UIStackView().apply {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 16
    }
    
    // Dependencies
    private let interactor: OnboardingBusinessLogic?
    private let viewModel: OnboardingViewModel?
    let dismissOnClose: Bool
    
    // Lifecycle
    init(
        viewModel: OnboardingViewModel?,
        interactor: OnboardingBusinessLogic?,
        dismissOnClose: Bool
    ) {
        self.viewModel = viewModel
        self.interactor = interactor
        self.dismissOnClose = dismissOnClose
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported initialization")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareLayout()
        bindViewModel()
    }
    
    // Configuration
    func prepareView() {
        view.backgroundColor = UIColor(red: 0.09, green: 0.08, blue: 0.19, alpha: 1)
        
        backgroundImageView.image = viewModel?.backgroundImage
        headerLabel.text = viewModel?.titleText
        descriptionLabel.text = viewModel?.descriptionText
        
        if viewModel?.needRating == true {
            SKStoreReviewController.requestReview()
        }
        
        [
            FooterButtonConfig.init(title: "Privacy".localized, action: #selector(OnboardingViewController.didTapPrivacyButton)),
            FooterButtonConfig.init(title: "Restore".localized, action: #selector(OnboardingViewController.didTapRestoreButton)),
            FooterButtonConfig.init(title: "Terms".localized, action: #selector(OnboardingViewController.didTapTermsButton))
        ].forEach { buttonConfig in
            let button = UIButton(type: .system)
            button.setTitle(buttonConfig.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(
                ofSize: Locale.current.isEnglish ? 14 : 10,
                weight: .regular
            )
            button.setTitleColor(UIColor(red: 0.4, green: 0.48, blue: 0.7, alpha: 1), for: .normal)
            button.addTarget(self, action: buttonConfig.action, for: .touchUpInside)
            footerButtonsStack.addArrangedSubview(button)
        }
    }
    
    func prepareLayout() {
        let isCompactDevice = UIScreen.main.bounds.height < 700
        
        view.addSubviews(
            backgroundImageView,
            headerLabel,
            descriptionLabel,
            actionButton,
            footerButtonsStack
        )
        
        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(isCompactDevice ? 149 : 149)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(actionButton.snp.top)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(66)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        actionButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-59)
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(69)
        }
        
        footerButtonsStack.snp.makeConstraints {
            $0.top.equalTo(actionButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(26)
            $0.height.equalTo(18)
        }
    }
    
    private func bindViewModel() {
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .subscribe(onNext: { [weak self] isPremium in
                if isPremium {
                    if self?.dismissOnClose == true {
                        self?.dismiss()
                    } else {
                        self?.interactor?.completeOnboarding()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // Actions
    @objc func didTapActionButton() {
        interactor?.proceedToNextStep()
    }
    
    @objc func didTapPrivacyButton() {
        interactor?.showPrivacyPolicy()
    }
    
    @objc func didTapTermsButton() {
        interactor?.showTermsOfService()
    }
    
    @objc func didTapRestoreButton() {
        interactor?.restorePurchases()
    }
}
