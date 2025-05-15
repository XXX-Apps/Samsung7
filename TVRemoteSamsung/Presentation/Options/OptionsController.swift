import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import SafariServices

class OptionsController: CommonController {
    private let contentProvider = MenuContentProvider()
    private let menuTableView = UITableView()
    private let navigationTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureContentProvider()
        configureNavigation()
    }
    
    private func configureViewHierarchy() {
        view.addSubview(menuTableView)
        menuTableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        menuTableView.register(
            PremiumPromotionCell.self,
            forCellReuseIdentifier: PremiumPromotionCell.reuseID
        )
        menuTableView.register(
            CommonCell.self,
            forCellReuseIdentifier: CommonCell.reuseID
        )
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.backgroundColor = .clear
        menuTableView.separatorStyle = .none
        menuTableView.contentInset.top = 20
        menuTableView.contentInset.bottom = 100
    }
    
    private func configureContentProvider() {
        contentProvider.delegate = self
        contentProvider.rebuildMenu(forPremiumStatus: PremiumManager.shared.isPremium.value)
    }
    
    private func configureNavigation() {
        navigationTitle.text = "Options".localized
        navigationTitle.font = .font(weight: .medium, size: 16)
        configurNavigation(centerView: navigationTitle)
    }
}

extension OptionsController: MenuContentUpdatable {
    func menuContentDidChange() {
        menuTableView.reloadData()
    }
}

extension OptionsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentProvider.currentRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch contentProvider.currentRows[indexPath.row] {
        case .premiumPromotion:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PremiumPromotionCell.reuseID,
                for: indexPath
            ) as! PremiumPromotionCell
            return cell
            
        case .standardOption(let option):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommonCell.reuseID,
                for: indexPath
            ) as! CommonCell
            cell.configure(type: option)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        switch contentProvider.currentRows[indexPath.row] {
        case .premiumPromotion:
            presentPremiumPaywall()
            
        case .standardOption(let option):
            handleMenuOptionSelection(option)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch contentProvider.currentRows[indexPath.row] {
        case .premiumPromotion: return UITableView.automaticDimension
        case .standardOption: return 86
        }
    }
    
    private func handleMenuOptionSelection(_ option: AppMenuOption) {
        switch option {
        case .shareApp:
            presentShareSheet()
        case .privacyPolicy:
            presentWebView(urlString: Config.privacy)
        case .termsOfService:
            presentWebView(urlString: Config.terms)
        case .alternateIcons:
            presentIconSelection()
        }
    }
    
    private func presentShareSheet() {
        let appStoreURL = URL(string: "https://apps.apple.com/us/app/\(Config.appId)")!
        let activityVC = UIActivityViewController(activityItems: [appStoreURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        present(activityVC, animated: true)
    }
    
    private func presentWebView(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func presentPremiumPaywall() {
        guard PremiumManager.shared.isPremium.value else {
            return
        }
        let vc = PaywallViewController(
            interactor: OnboardingInteractor(
                coordinator: OnboardingCoordinator(window: nil)
            )
        )
        present(vc: vc)
    }
    
    private func presentIconSelection() {
        presentCrossDissolve(vc: IconSelectionViewController())
    }
}
