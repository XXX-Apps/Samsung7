import UIKit
import SnapKit
import ShadowImageButton
import Utilities

class PremiumPromotionCell: UITableViewCell {
    static let reuseID = "PremiumPromotionCell"
    
    private let containerView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "premiumCell"))
        view.applyDropShadow(
            color: UIColor(hex: "117FF5"),
            opacity: 0.6,
            offset: CGSize(width: 0, height: 4),
            radius: 14.7
        )
        return view
    }()
    
    private let promotionTitle: UILabel = {
        let label = UILabel()
        label.text = "Try Premium".localized
        label.font = .font(weight: .medium, size: 20)
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let promotionSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Control your TV seamlessly".localized
        label.font = .font(weight: .semiBold, size: 12)
        label.textColor = UIColor(hex: "9EC1FF")
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Try now".localized, for: .normal)
        button.titleLabel?.font = .font(weight: .semiBold, size: 16)
        button.setTitleColor(UIColor(hex: "0434ED"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 17
        button.applyDropShadow(
            color: .white,
            opacity: 0.6,
            offset: CGSize(width: 0, height: 4),
            radius: 17
        )
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(promotionTitle, promotionSubtitle, actionButton)
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(containerView.snp.width).multipliedBy(116.0/345.0)
            $0.verticalEdges.equalToSuperview().inset(20)
        }
        
        promotionTitle.snp.makeConstraints {
            $0.leading.equalTo(actionButton)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(promotionSubtitle.snp.top).offset(-6)
        }
        
        promotionSubtitle.snp.makeConstraints {
            $0.leading.equalTo(actionButton)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(actionButton.snp.top).offset(-12)
        }
        
        actionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(59)
            $0.bottom.equalToSuperview().inset(15)
            $0.size.equalTo(CGSize(width: 127, height: 34))
        }
    }
}

// MARK: - Extensions

extension UIView {
    func applyDropShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
