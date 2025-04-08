import UIKit
import Utilities

enum OptionType {
    case share
    case terms
    case privacy
    case changeIcon
    
    var image: UIImage? {
        switch self {
        case .share: return UIImage(named: "share")
        case .privacy: return UIImage(named: "privacy")
        case .terms: return UIImage(named: "terms")
        case .changeIcon: return UIImage(named: "switchIcon")
        }
    }
    
    var title: String {
        switch self {
        case .share: return "Share the app".localized
        case .privacy: return "Privacy Policy".localized
        case .terms: return "Terms of Use".localized
        case .changeIcon: return "Switch app icon".localized
        }
    }
}

enum OptionCellType {
    case premium
    case settings(type: OptionType)
}

final class OptionsViewModel {
    
    var onUpdate: (() -> Void)?
    
    var cells: [OptionCellType] = []
    
    func configureCells(isPremium: Bool = false) {
        
        cells.removeAll()
        
        if !isPremium {
            cells.append(.premium)
        }
        cells.append(.settings(type: .changeIcon))
        cells.append(.settings(type: .share))
        cells.append(.settings(type: .privacy))
        cells.append(.settings(type: .terms))
        
        onUpdate?()
    }
}
