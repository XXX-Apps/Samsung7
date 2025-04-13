import UIKit
import SafariServices
import SnapKit
import CustomBlurEffectView
import ShadowImageButton
import Utilities

// MARK: - Constants

private enum Constants {
    static let contentViewHeight: CGFloat = 461
    static let buttonHeight: CGFloat = 62
    static let cornerRadius: CGFloat = 30
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
    static let contentInsets = UIEdgeInsets(top: 0, left: 28, bottom: 61, right: 28)
    static let textInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
}

// MARK: - ReviewController

final class ReviewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var blurView = CustomBlurEffectView().then {
        $0.blurRadius = 3
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
    }
    
    private lazy var contentView = UIView().then {
        $0.backgroundColor = UIColor(hex: "31337C")
        $0.layer.cornerRadius = Constants.cornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private lazy var appImageView = UIImageView().then {
        $0.image = .review
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = .font(weight: .medium, size: 24)
        $0.text = "Would you recommend us?".localized
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private lazy var subtitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = UIColor(hex: "8196CE")
        $0.font = .font(weight: .medium, size: 20)
        $0.text = "Your feedback helps us enhance your experience".localized
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private lazy var feedbackButton = ShadowImageButton().then {
        $0.configure(
            buttonConfig: .init(
                title: "Leave feedback".localized,
                font: .font(weight: .medium, size: 18),
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
        $0.action = { [weak self] in self?.handleFeedbackAction() }
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setTitle("Not now".localized, for: .normal)
        $0.titleLabel?.font = .font(weight: .regular, size: 16)
        $0.setTitleColor(UIColor(hex: "667BB3"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureLayoutConstraints()
        markFeedbackAsShown()
    }
    
    // MARK: - Private Methods
    
    private func configureViewHierarchy() {
        view.addSubview(blurView)
        blurView.addSubview(contentView)
        
        contentView.addSubviews(
            appImageView,
            titleLabel,
            subtitleLabel,
            feedbackButton,
            closeButton
        )
    }
    
    private func configureLayoutConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Constants.contentViewHeight)
        }
        
        appImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-10)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(Constants.textInsets)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(feedbackButton.snp.top).offset(-40)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        feedbackButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.contentInsets)
            $0.height.equalTo(Constants.buttonHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.contentInsets.bottom)
        }
        
        closeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(21)
        }
    }
    
    private func markFeedbackAsShown() {
        LocalDataBase.shared.wasRevviewScreen = true
    }
    
    private func presentAppStoreReview() {
        guard let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(Config.appId)?action=write-review") else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleCloseAction() {
        generateHapticFeedback()
        dismiss(animated: true)
    }
    
    @objc private func handleFeedbackAction() {
        generateHapticFeedback()
        presentAppStoreReview()
    }
}

// MARK: - Then Protocol

protocol Then {}
extension Then where Self: AnyObject {
    @discardableResult
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

extension NSObject: Then {}
