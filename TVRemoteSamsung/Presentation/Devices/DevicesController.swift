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

final class DevicesController: CommonController {
    
    // MARK: - UI Components
    
    private lazy var navigationTitleLabel = UILabel().then {
        $0.text = "Connections".localized
        $0.font = .font(weight: .medium, size: 16)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(named: "circleClose"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    private lazy var guideButton = UIButton().then {
        let title = "Can’t connect".localized
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.titleLabel?.font = .font(weight: .regular, size: 16)
        $0.setTitleColor(UIColor(hex: "667BB3"), for: .normal)
        $0.addTarget(self, action: #selector(handleOpenGuide), for: .touchUpInside)
    }
    
    private lazy var tryAgainButton = ShadowImageButton().then {
        $0.configure(
            buttonConfig: .init(
                title: "Try again".localized,
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
        $0.action = { [weak self] in self?.handleTryAgainAction() }
        $0.isHidden = true
    }
    
    private lazy var tableView = UITableView().then {
        $0.register(CommonCell.self, forCellReuseIdentifier: CommonCell.reuseID)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    // MARK: - Properties
    
    private let viewModel = DevicesViewModel()
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
        configurNavigation(centerView: navigationTitleLabel, rightView: closeButton)
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(
            tryAgainButton,
            tableView,
            guideButton
        )
        
        tryAgainButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(62)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(61)
        }
        
        guideButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(30)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(20)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupObservers() {
//        SamsungTVConnectionService.shared.connectionStatusPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isConnected in
//                self?.updateUI(forConnectionStatus: isConnected)
//            }
//            .store(in: &cancellables)
    }
    
    private func updateUI(forConnectionStatus isConnected: Bool) {
        tableView.reloadData()
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleTryAgainAction() {
        generateHapticFeedback()
    }
    
    @objc private func handleCloseAction() {
        generateHapticFeedback()
        dismiss(animated: true)
    }
    
    @objc private func handleOpenGuide() {
        generateHapticFeedback()
        presentCrossDissolve(vc: GuideController())
    }
}

// MARK: - TableView Delegate & DataSource

extension DevicesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CommonCell.reuseID,
            for: indexPath
        ) as! CommonCell
        
//        let app = viewModel.availableApps[indexPath.row]
//        cell.configure(app: app)
        
        return cell
    }
}

extension DevicesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generateHapticFeedback()
//        let selectedApp = viewModel.availableApps[indexPath.row]
//        
//        try? viewModel.launchApplication(selectedApp)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}
