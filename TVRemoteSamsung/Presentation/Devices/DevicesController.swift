import SnapKit
import UIKit
import TVRemoteControl
import ShadowImageButton
import Utilities
import CustomBlurEffectView

// MARK: - Constants

private enum LayoutConstants {
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
    static let headerCellHeight: CGFloat = 450
    static let deviceCellHeight: CGFloat = 106
    static let infoViewHeight: CGFloat = 128
    static let successInfoViewHeight: CGFloat = 283
}

// MARK: - View Controller

final class DevicesController: CommonController {
    
    // MARK: - UI Components
    
    private lazy var blurView = CustomBlurEffectView().then {
        $0.blurRadius = 3
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
        $0.isHidden = true
    }
    
    private lazy var infoView = InfoActionView().then {
        $0.onActionButtonTap = { [weak self] in
            self?.blurView.isHidden = true
        }
    }
    
    private lazy var shadowImageView = UIImageView(image: UIImage(named: "devicesShadow")).then {
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var navigationTitleLabel = UILabel().then {
        $0.text = "Connections".localized
        $0.font = .font(weight: .medium, size: 16)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(named: "circleClose"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    private lazy var guideButton = UIButton().then {
        let title = "Can't connect".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        $0.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
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
                cornerRadius: LayoutConstants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "117FF5"),
                    opacity: LayoutConstants.shadowOpacity,
                    offset: LayoutConstants.shadowOffset,
                    radius: LayoutConstants.shadowRadius
                )
            )
        )
        $0.action = { [weak self] in self?.handleTryAgainAction() }
        $0.isHidden = true
    }
    
    private lazy var tableView = UITableView().then {
        $0.register(DeviceCell.self, forCellReuseIdentifier: DeviceCell.reuseID)
        $0.register(DeviceHeaderCell.self, forCellReuseIdentifier: DeviceHeaderCell.reuseID)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.contentInset = calculateContentInset()
    }
    
    // MARK: - Properties
    
    private let viewModel = DevicesViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        setupViewHierarchy()
        setupControllerConstraints()
        setupObservers()
        
        LocalNetworkAuthorization().requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    self.viewModel.startSearch()
                } else {
                    self.dismiss(animated: true) {
                        UIApplication.topViewController()?.showAlert(
                            title: "You need to grant access to the network".localized,
                            message: "Go to Settings > Privacy > Network > [Your Device Name]".localized
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureNavigation() {
        configurNavigation(centerView: navigationTitleLabel, rightView: closeButton)
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(tableView, shadowImageView, tryAgainButton, guideButton, blurView)
        blurView.addSubview(infoView)
    }
    
    private func setupControllerConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        infoView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(LayoutConstants.infoViewHeight)
            $0.width.equalTo(345)
        }
        
        shadowImageView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIScreen.isLittleDevice ? 100 : 220)
        }
        
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
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    private func calculateContentInset() -> UIEdgeInsets {
        let topInset = ((view.bounds.height - 30) - LayoutConstants.headerCellHeight) / 4
        return UIEdgeInsets(
            top: max(topInset, 0),
            left: 0,
            bottom: 150,
            right: 0
        )
    }
    
    private func setupObservers() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onConnected = { [weak self] in
            self?.showConnectionSuccess()
        }
        
        viewModel.onConnecting = { [weak self] in
            self?.showConnectingState()
        }
        
        viewModel.onConnectionError = { [weak self] in
            self?.showConnectionError()
        }
        
        viewModel.onNotFound = { [weak self] in
            self?.showNoDevicesFound()
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let isEmpty = viewModel.devices.isEmpty
            shadowImageView.isHidden = isEmpty
            tryAgainButton.isHidden = true
            
            if !isEmpty {
                tableView.contentInset = UIEdgeInsets(top: UIScreen.isLittleDevice ? -80 : 0, left: 0, bottom: 100, right: 0)
            }
            
            tableView.reloadData()
        }
    }
    
    private func showConnectionSuccess() {
        DispatchQueue.main.async { [weak self] in
            self?.infoView.snp.updateConstraints {
                $0.height.equalTo(LayoutConstants.successInfoViewHeight)
            }
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                image: UIImage(named: "success"),
                title: "Connection succeed!".localized,
                subtitle: "You can start using your remote".localized,
                needButton: true
            )
        }
    }
    
    private func showConnectingState() {
        DispatchQueue.main.async { [weak self] in
            self?.infoView.snp.updateConstraints {
                $0.height.equalTo(LayoutConstants.infoViewHeight)
            }
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                title: "Connection in progress...".localized,
                subtitle: "Please, don't close the app".localized,
                needButton: false
            )
        }
    }
    
    private func showConnectionError() {
        DispatchQueue.main.async { [weak self] in
            self?.infoView.snp.updateConstraints {
                $0.height.equalTo(LayoutConstants.successInfoViewHeight)
            }
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                image: UIImage(named: "error"),
                title: "Trouble connecting".localized,
                subtitle: "Please, try again".localized,
                needButton: true
            )
        }
    }
    
    private func showNoDevicesFound() {
        DispatchQueue.main.async { [weak self] in
            self?.tryAgainButton.isHidden = false
            self?.tableView.reloadData()
        }
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleTryAgainAction() {
        generateHapticFeedback()
        viewModel.startSearch()
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

// MARK: - UITableViewDataSource & Delegate

extension DevicesController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DeviceHeaderCell.reuseID,
                for: indexPath
            ) as! DeviceHeaderCell
            cell.configure(isNotFound: viewModel.devicesNotFound)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DeviceCell.reuseID,
            for: indexPath
        ) as! DeviceCell
        cell.configure(tv: viewModel.devices[indexPath.row])
        return cell
    }
}

extension DevicesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        generateHapticFeedback()
        viewModel.connect(device: viewModel.devices[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? LayoutConstants.headerCellHeight : LayoutConstants.deviceCellHeight
    }
}
