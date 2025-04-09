import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import TVRemoteControl
import ShadowImageButton

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

final class ApplicationsController: CommonController {
    
    private let viewModel = ApplicationsViewModel()
    
    private let connectionManager = SamsungTVConnectionService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Platforms".localized
        label.font = .font(weight: .medium, size: 16)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(CommonCell.self, forCellReuseIdentifier: CommonCell.reuseID)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.isHidden = true
        return tableView
    }()
    
    private lazy var imageView: UIImageView = {
        UIImageView(image: UIImage(named: "appsConnection"))
    }()
    
    private lazy var connectTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .font(weight: .medium, size: 20)
        view.text = "Connection needed".localized
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var connectSubitleLabel: UILabel = {
        let view = UILabel()
        view.font = .font(weight: .medium, size: 15)
        view.textColor = .init(hex: "667BB3")
        view.textAlignment = .center
        view.text = "You need to connect your phone and TV to open applications".localized
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var connectStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [connectTitleLabel, connectSubitleLabel])
        view.axis = .vertical
        view.spacing = 15
        return view
    }()
    
    private lazy var bottomButton = ShadowImageButton().then {
        $0.configure(
            buttonConfig: .init(
                title: "Make new connection".localized,
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
        $0.action = { [weak self] in self?.openConnect() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configurNavigation(
            centerView: titleLabel
        )
        
        setupUI()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        connectionManager
            .connectionStatusPublisher
            .sink { isConnected in
                DispatchQueue.main.async {
                    self.imageView.isHidden = isConnected
                    self.bottomButton.isHidden = isConnected
                    self.connectStackView.isHidden = isConnected
                    self.tableView.isHidden = !isConnected
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }
    
    private func setupUI() {
        view.addSubviews(imageView, bottomButton, connectStackView, tableView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.left.right.equalToSuperview()
        }
        
        connectStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(110)
            make.left.right.equalToSuperview().inset(50)
        }
        
        bottomButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(62)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(164)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    @objc private func openConnect() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()


    }
}

extension ApplicationsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.apps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let app = viewModel.apps[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommonCell.reuseID) as? CommonCell else {
            fatalError("Could not dequeue CommonCell")
        }
        
        cell.configure(app: app)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let app = viewModel.apps[indexPath.row]
        viewModel.openApp(app: app)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 102
    }
}

