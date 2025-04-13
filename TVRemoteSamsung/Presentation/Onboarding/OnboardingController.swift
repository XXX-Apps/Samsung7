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

class OnboardingController: UIViewController {
    
    let imageView = MyImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    private let bottomStackView = UIStackView()
    
    private let disposeBag = DisposeBag()
    
    private lazy var nextButton: ShadowImageButton = {
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
        button.action = { [weak self] in
            self?.nextButtonTapped()
        }
        return button
    }()
    
    private weak var coordinator: OnboardingCoordinator?
    private var model: OnboardingModel?
    
    init(
        model: OnboardingModel,
        coordinator: OnboardingCoordinator
    ) {
        self.model = model
        self.coordinator = coordinator
     
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isPremium in
                if isPremium {
                    self.closeAction()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.backgroundColor = .init(hex: "161430")
        
        imageView.image = model?.image
        imageView.aspectFill = true
        imageView.verticalAlignment = .top
        view.addSubview(imageView)
        
        titleLabel.text = model?.title
        titleLabel.font = .font(weight: .medium, size: 26)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        subtitleLabel.text = model?.subtitle
        subtitleLabel.font = .font(weight: .medium, size: 16)
        subtitleLabel.textColor = .init(hex: "667BB3")
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)
        
        view.addSubview(nextButton)
        
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 16
        
        let privacyButton = createBottomButton(title: "Privacy".localized)
        let restoreButton = createBottomButton(title: "Restore".localized)
        let termsButton = createBottomButton(title: "Terms".localized)
        
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        bottomStackView.addArrangedSubview(privacyButton)
        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(termsButton)
        
        view.addSubview(bottomStackView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIScreen.isLittleDevice ? 149 : 149)
            make.bottom.equalTo(nextButton.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(66)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(107)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-59)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(69)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(26)
            make.height.equalTo(18)
        }
    }
    
    private func createBottomButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.init(hex: "667BB3"), for: .normal)
        button.titleLabel?.font = .font(weight: .regular, size: Locale().isEnglish ? 14 : 10)
        return button
    }
    
    @objc private func nextButtonTapped() {
        bottomButtonAction()
    }
    
    func bottomButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if model?.rating == true {
            SKStoreReviewController.requestReview()
        }
        coordinator?.goToNextScreen()
    }
    
    @objc private func openPrivacy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: Config.privacy) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc private func openTerms() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: Config.terms) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc private func restore() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        PremiumManager.shared.restorePurchases()
    }
    
    @objc private func close() {
        closeAction()
    }
    
    func closeAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        replaceRootViewController(with: TabBarConfigurator.main())
    }
}
