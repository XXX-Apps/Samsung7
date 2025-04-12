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
    static let headerCellHeight: CGFloat = 400
}

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
    
    private lazy var shadowImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "devicesShadow"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
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
        $0.register(DeviceCell.self, forCellReuseIdentifier: DeviceCell.reuseID)
        $0.register(DeviceHeaderCell.self, forCellReuseIdentifier: DeviceHeaderCell.reuseID)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        
        let topInset = ((view.bounds.height - 30) - Constants.headerCellHeight) / 4
        
        $0.contentInset = UIEdgeInsets(
            top: max(topInset, 0),
            left: 0,
            bottom: 100,
            right: 0
        )
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
            tableView,
            shadowImageView,
            tryAgainButton,
            guideButton,
            blurView
        )
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurView.addSubviews(infoView)
        
        infoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(128)
            make.width.equalTo(345)
        }
        
        shadowImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(220)
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
            $0.bottom.left.right.equalToSuperview()
        }
    }
    
    private func setupObservers() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            let isEmpty = viewModel.devices.isEmpty
            
            DispatchQueue.main.async {
                self.shadowImageView.isHidden = isEmpty
                self.tryAgainButton.isHidden = true
                self.tableView.reloadData()
                
                if !isEmpty {
                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
                }
            }
        }
        
        viewModel.onConnected = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.infoView.snp.updateConstraints { make in
                    make.height.equalTo(283)
                }
                
                self.blurView.isHidden = false
                self.infoView.configure(
                    image: UIImage(named: "success"),
                    title: "Connection succeed!".localized,
                    subtitle: "You can start using your remote".localized,
                    needButton: true
                )
            }
        }
        
        viewModel.onConnecting = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.infoView.snp.updateConstraints { make in
                    make.height.equalTo(128)
                }
                
                self.blurView.isHidden = false
                self.infoView.configure(
                    title: "Connection in progress...".localized,
                    subtitle: "Please, don’t close the app".localized,
                    needButton: false
                )
            }
        }
        
        viewModel.onConnectionError = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.infoView.snp.updateConstraints { make in
                    make.height.equalTo(283)
                }
                
                self.blurView.isHidden = false
                self.infoView.configure(
                    image: UIImage(named: "error"),
                    title: "Trouble connecting".localized,
                    subtitle: "Please, try again".localized,
                    needButton: true
                )
            }
        }
        
        viewModel.onNotFound = { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.tryAgainButton.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleTryAgainAction() {
        generateHapticFeedback()
        viewModel.reload()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return viewModel.devices.count
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
        
        let model = viewModel.devices[indexPath.row]
        cell.configure(tv: model)
        
        return cell
    }
}

extension DevicesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generateHapticFeedback()
        let tv = viewModel.devices[indexPath.row]
        viewModel.connect(tv: tv)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Constants.headerCellHeight
        }
        return 106
    }
}
