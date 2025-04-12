import UIKit
import SnapKit
import Utilities
import ShadowImageButton

private enum Constants {
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
}

final class InfoActionView: UIView {
    
    // MARK: - UI Components
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel, actionButton])
        stack.axis = .vertical
        stack.setCustomSpacing(15, after: imageView)
        stack.setCustomSpacing(28, after: subtitleLabel)
        stack.setCustomSpacing(10, after: titleLabel)
        stack.alignment = .center
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 16)
        label.textColor = .init(hex: "667BB3")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var actionButton = ShadowImageButton().then {
        $0.configure(
            buttonConfig: .init(
                title: "Okay".localized,
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
        $0.action = { [weak self] in self?.buttonTapped() }
    }
    
    // MARK: - Properties
    
    var onActionButtonTap: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        
        backgroundColor = .init(hex: "31337C")
        layer.cornerRadius = 28
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(65)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.height.equalTo(21)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(21)
            make.centerX.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(297)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func buttonTapped() {
        onActionButtonTap?()
    }
    
    // MARK: - Public Methods
    
    func configure(
        image: UIImage? = nil,
        title: String?,
        subtitle: String?,
        needButton: Bool
    ) {
        imageView.image = image
        imageView.isHidden = image == nil
        
        titleLabel.text = title
        titleLabel.isHidden = title == nil
        
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        
        actionButton.isHidden = !needButton
    }
}
