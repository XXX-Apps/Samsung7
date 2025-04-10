import UIKit
import SafariServices
import SnapKit
import CustomBlurEffectView
import ShadowImageButton
import Utilities

// MARK: - Constants

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

// MARK: - ReviewController

final class GuideController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var blurView = CustomBlurEffectView().then {
        $0.blurRadius = 3
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
    }
    
    private lazy var contentView = UIView().then {
        $0.backgroundColor = UIColor(hex: "31337C")
        $0.layer.cornerRadius = Constants.cornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private lazy var navigationTitleLabel = UILabel().then {
        $0.text = "Advices for connecting".localized
        $0.font = .font(weight: .medium, size: 16)
        $0.textAlignment = .center
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    private lazy var tableView = UITableView().then {
        $0.register(GuideCell.self, forCellReuseIdentifier: GuideCell.reuseID)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        $0.showsVerticalScrollIndicator = false
    }
    
    let viewModel = GuideViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureLayoutConstraints()
    }
    
    // MARK: - Private Methods
    
    private func configureViewHierarchy() {
        view.addSubview(blurView)
        blurView.addSubview(contentView)
        
        contentView.addSubviews(
            navigationTitleLabel,
            closeButton,
            tableView
        )
    }
    
    private func configureLayoutConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        navigationTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.trailing.equalToSuperview().inset(Constants.textInsets)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(25)
            $0.height.width.equalTo(20)
        }
        
        tableView.snp.makeConstraints {
            $0.bottom.right.left.equalToSuperview()
            $0.top.equalToSuperview().inset(90)
        }
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleCloseAction() {
        generateHapticFeedback()
        dismiss(animated: true)
    }
}

// MARK: - TableView Delegate & DataSource

extension GuideController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: GuideCell.reuseID,
            for: indexPath
        ) as! GuideCell
        
        let model = viewModel.models[indexPath.row]
        cell.configure(model: model)
        
        return cell
    }
}

extension GuideController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
