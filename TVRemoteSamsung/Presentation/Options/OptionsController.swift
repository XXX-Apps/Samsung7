import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import SafariServices

final class OptionsController: CommonController {
    
    private let viewModel = OptionsViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Options".localized
        label.font = .font(weight: .medium, size: 16)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(OptionsPremiumCell.self, forCellReuseIdentifier: OptionsPremiumCell.identifier)
        tableView.register(CommonCell.self, forCellReuseIdentifier: CommonCell.identifier)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalDataBase.shared.isOnboardingShown = true
        
        configurNavigation(
            centerView: titleLabel
        )
        
        setupUI()
        setupSubscriptions()
        
        viewModel.configureCells(isPremium: false)
    }
    
    func setupUI() {
        
        view.addSubview(tableView)
    
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupSubscriptions() {
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isPremium in
                self.viewModel.configureCells(isPremium: isPremium)
            })
            .disposed(by: disposeBag)
        
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func openPaywall() {

    }
    
    private func openShare() {
        let appURL = URL(string: "https://apps.apple.com/us/app/\(Config.appId)")!
        let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true)
    }
    
    private func openPrivacy() {
        if let url = URL(string: Config.privacy) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: Config.terms) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    private func openChangeIcon() {

    }
}

extension OptionsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModel.cells[indexPath.row]
        
        switch cellType {
        case .premium:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionsPremiumCell.identifier) as? OptionsPremiumCell else {
                fatalError("Could not dequeue SettingsPremiumCell")
            }
            return cell
        case .settings(let type):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommonCell.identifier) as? CommonCell else {
                fatalError("Could not dequeue SettingsPremiumCell")
            }
            cell.configure(type: type)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let cellType = viewModel.cells[indexPath.row]
        
        switch cellType {
        case .premium:
            openPaywall()
        case .settings(let type):
            switch type {
            case .share:
                openShare()
            case .privacy:
                openPrivacy()
            case .terms:
                openTerms()
            case .changeIcon:
                openChangeIcon()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = viewModel.cells[indexPath.row]
        
        switch cellType {
        case .premium:
            return UITableView.automaticDimension
        case .settings:
            return 86
        }
    }
}

