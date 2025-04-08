import Combine
import PremiumManager
import UIKit
import Foundation
import Utilities
import RxSwift

protocol MenuOptionRepresentable {
    var iconAsset: UIImage? { get }
    var displayTitle: String { get }
}

enum AppMenuOption: MenuOptionRepresentable {
    case shareApp
    case privacyPolicy
    case termsOfService
    case alternateIcons
    
    var iconAsset: UIImage? {
        switch self {
        case .shareApp: return UIImage(named: "share")
        case .privacyPolicy: return UIImage(named: "privacy")
        case .termsOfService: return UIImage(named: "terms")
        case .alternateIcons: return UIImage(named: "switchIcon")
        }
    }
    
    var displayTitle: String {
        switch self {
        case .shareApp: return "Share the app".localized
        case .privacyPolicy: return "Privacy Policy".localized
        case .termsOfService: return "Terms of Use".localized
        case .alternateIcons: return "Switch app icon".localized
        }
    }
}

enum MenuRowConfiguration {
    case premiumPromotion
    case standardOption(AppMenuOption)
}

// MARK: - View Model

protocol MenuContentUpdatable: AnyObject {
    func menuContentDidChange()
}

class MenuContentProvider {
    weak var delegate: MenuContentUpdatable?
    
    private let disposeBag = DisposeBag()
    
    private(set) var currentRows: [MenuRowConfiguration] = []
    
    init() {
        setupPremiumSubscription()
    }
    
    func rebuildMenu(forPremiumStatus isPremium: Bool = false) {
        currentRows.removeAll()
        
        if !isPremium {
            currentRows.append(.premiumPromotion)
        }
        
        let standardOptions: [AppMenuOption] = [
            .alternateIcons,
            .shareApp,
            .privacyPolicy,
            .termsOfService
        ]
        
        currentRows += standardOptions.map { .standardOption($0) }
        delegate?.menuContentDidChange()
    }
    
    private func setupPremiumSubscription() {
        
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isPremium in
                self.rebuildMenu(forPremiumStatus: isPremium)
            })
            .disposed(by: disposeBag)
    }
}

