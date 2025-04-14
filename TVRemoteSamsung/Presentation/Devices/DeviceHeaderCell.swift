import UIKit
import SnapKit
import ShadowImageButton
import Utilities
import Lottie

final class DeviceHeaderCell: UITableViewCell {
    
    static let reuseID = "SearchCell"
    
    private let tvImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tv"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let centerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bigWifi"))
        return imageView
    }()


    private lazy var animationView: LottieAnimationView = {
        let path = Bundle.main.path(
            forResource: "search",
            ofType: "json"
        ) ?? ""
        let animationView = LottieAnimationView(filePath: path)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        return animationView
    }()
    
    private lazy var connectionTitleLabel = UILabel().then {
        $0.font = .font(weight: .medium, size: 20)
        $0.text = "Looking for devices...".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionSubtitleLabel = UILabel().then {
        $0.font = .font(weight: .medium, size: 15)
        $0.textColor = UIColor(hex: "667BB3")
        $0.text = "Ensure that your phone and TV are on the same Wi-Fi connection".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionStackView = UIStackView(arrangedSubviews: [
        connectionTitleLabel,
        connectionSubtitleLabel
    ]).then {
        $0.axis = .vertical
        $0.spacing = 15
    }

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
        
        contentView.addSubview(tvImageView)
        contentView.addSubview(animationView)
        contentView.addSubview(connectionStackView)
        contentView.addSubview(centerImageView)
        
        tvImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(-200)
//            make.width.equalTo(tvImageView.snp.height)
            make.centerX.equalToSuperview()
        }
       
        animationView.snp.makeConstraints { make in
            make.height.width.equalTo(234)
            make.center.equalTo(tvImageView)
        }
        
        centerImageView.snp.makeConstraints { make in
            make.height.width.equalTo(76)
            make.center.equalTo(tvImageView)
        }
        
        connectionStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(81)
        }
    }
    
    func configure(isNotFound: Bool) {
        centerImageView.image = UIImage(named: isNotFound ? "notFound" : "bigWifi")
        connectionTitleLabel.text = isNotFound ? "No connections found".localized : "Looking for devices...".localized
        connectionSubtitleLabel.text = isNotFound ? "Ensure that your phone and TV are on the same Wi-Fi connection".localized : "Ensure that your phone and TV are on the same Wi-Fi connection".localized
        
        centerImageView.snp.updateConstraints { make in
            make.height.width.equalTo(isNotFound ? 50 : 76)
        }
    }
}

