import Utilities
import UIKit
import SnapKit

final class CommonCell: UITableViewCell {
    
    static let identifier = "CommonCell"
    
    private lazy var customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "31337C")
        view.layer.cornerRadius = 32
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 18)
        label.textColor = .white
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
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(26)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(32)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(72)
            make.right.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(type: OptionType) {
        titleLabel.text = type.title
        leftImageView.image = type.image
    }
    
//    func configure(app: TVApp) {
//        titleLabel.text = app.name
//        leftImageView.image = app.image
//        
//        leftImageView.snp.updateConstraints { make in
//            make.height.width.equalTo(50)
//        }
//        
//        titleLabel.snp.updateConstraints { make in
//            make.left.equalToSuperview().inset(96)
//        }
//    }
}
