import UIKit
import SnapKit
import TVRemoteControl

final class DeviceCell: UITableViewCell {
    
    static let reuseID = "DeviceCell"
    
    private lazy var customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "31337C")
        view.layer.cornerRadius = 36
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
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .regular, size: 16)
        label.textColor = .init(hex: "7E94CE")
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
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
        customBackgroundView.addSubview(stackView)
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(60)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(94)
            make.right.equalToSuperview().inset(26)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(tv: SamsungTVModel) {
        
        titleLabel.text = tv.name.decodingHTMLEntities()
        
        let isConnected = SamsungTVConnectionService.shared.connectedDevice?.id == tv.id
        
        subtitleLabel.text = isConnected ? "Connected".localized : "No connection".localized
        subtitleLabel.textColor = isConnected ? UIColor.init(hex: "18A2FA") : .init(hex: "7E94CE")
        
        leftImageView.image = UIImage(named: isConnected ? "connectedTV" : "notConnectedTV")
    }
}
