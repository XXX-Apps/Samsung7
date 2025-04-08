import UIKit
import SnapKit
import ShadowImageButton
import Utilities

final class OptionsPremiumCell: UITableViewCell {
    
    static let identifier = "OptionsPremiumCell"
    
    private lazy var customBackgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "premiumCell"))
        view.layer.shadowColor = UIColor.init(hex: "117FF5").cgColor
        view.layer.shadowOpacity = 0.6
        view.layer.shadowOffset = .init(width: 0, height: 4)
        view.layer.shadowRadius = 14.7
        view.layer.masksToBounds = false
        return view
    }()
    
    private let bottomButton: ShadowImageButton = {
        let button = ShadowImageButton()
        button.configure(
            buttonConfig: .init(
                title: "Try now".localized,
                font: .font(
                    weight: .semiBold,
                    size: 16
                ),
                textColor: .init(hex: "0434ED"),
                image: nil
            ),
            backgroundImageConfig: .init(
                image: nil,
                cornerRadius: 17,
                shadowConfig: .init(
                    color: .white,
                    opacity: 0.6,
                    offset: .init(width: 0, height: 4),
                    radius: 17
                )
            )
        )
        button.backgroundColor = .white
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 20)
        label.textColor = .white
        label.text = "Try Premium".localized
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .semiBold, size: 12)
        label.textColor = .init(hex: "9EC1FF")
        label.text = "Control your TV seamlessly".localized
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(customBackgroundView)
        
        customBackgroundView.addSubviews(
            titleLabel,
            subtitleLabel,
            bottomButton
        )
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(customBackgroundView.snp.width).multipliedBy(116.0 / 345.0)
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(bottomButton)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalTo(subtitleLabel.snp.top).inset(-6)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(bottomButton)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomButton.snp.top).inset(-12)
        }
        
        bottomButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(59)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(127)
            make.height.equalTo(34)
        }
    }
}

