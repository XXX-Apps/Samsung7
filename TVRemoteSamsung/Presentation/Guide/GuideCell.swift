import Utilities
import UIKit
import SnapKit
import TVRemoteControl

final class GuideCell: UITableViewCell {
    
    static let reuseID = "GuideCell"
    
    private lazy var customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "4A4CA9")
        view.layer.cornerRadius = 23
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 14)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .regular, size: 16)
        label.textColor = .white
        label.numberOfLines = 0
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
        
        customBackgroundView.addSubview(leftImageView)
        customBackgroundView.addSubview(titleLabel)
        customBackgroundView.addSubview(subtitleLabel)
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.width.equalTo(32)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(58)
            make.right.equalToSuperview().inset(22)
            make.centerY.equalTo(leftImageView)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(56)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(model: GuideModel) {
        titleLabel.text = model.title
        leftImageView.image = model.image
        subtitleLabel.text = model.subtitle
    }
}
