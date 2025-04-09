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
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
}

final class TVApplicationsViewController: CommonController {
    
    // MARK: - UI Components
    
    private lazy var navigationTitleLabel = UILabel().then {
        $0.text = "Platforms".localized
        $0.font = .font(weight: .medium, size: 16)
    }
    
    private lazy var connectionImageView = UIImageView(image: UIImage(named: "appsConnection")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var connectionTitleLabel = UILabel().then {
        $0.font = .font(weight: .medium, size: 20)
        $0.text = "Connection needed".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionSubtitleLabel = UILabel().then {
        $0.font = .font(weight: .medium, size: 15)
        $0.textColor = UIColor(hex: "667BB3")
        $0.text = "You need to connect your phone and TV to open applications".localized
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
    
    private lazy var connectButton = ShadowImageButton().then {
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
        $0.action = { [weak self] in self?.handleConnectAction() }
    }
    
    private lazy var appsTableView = UITableView().then {
        $0.register(CommonCell.self, forCellReuseIdentifier: CommonCell.reuseID)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        $0.isHidden = true
    }
    
    // MARK: - Properties
    
    private let viewModel = TVApplicationsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        setupViewHierarchy()
        setupObservers()
    }
    
    // MARK: - Private Methods
    
    private func configureNavigation() {
        configurNavigation(centerView: navigationTitleLabel)
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(
            connectionImageView,
            connectionStackView,
            connectButton,
            appsTableView
        )
        
        connectionImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.horizontalEdges.equalToSuperview()
        }
        
        connectionStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(110)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        connectButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(62)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(164)
        }
        
        appsTableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(20)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupObservers() {
        SamsungTVConnectionService.shared.connectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.updateUI(forConnectionStatus: isConnected)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(forConnectionStatus isConnected: Bool) {
        connectionImageView.isHidden = isConnected
        connectButton.isHidden = isConnected
        connectionStackView.isHidden = isConnected
        appsTableView.isHidden = !isConnected
        appsTableView.reloadData()
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleConnectAction() {
        generateHapticFeedback()
        // Handle connection action
    }
}

// MARK: - TableView Delegate & DataSource

extension TVApplicationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.availableApps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CommonCell.reuseID,
            for: indexPath
        ) as! CommonCell
        
        let app = viewModel.availableApps[indexPath.row]
        cell.configure(app: app)
        
        return cell
    }
}

extension TVApplicationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generateHapticFeedback()
        let selectedApp = viewModel.availableApps[indexPath.row]
        
        try? viewModel.launchApplication(selectedApp)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}
