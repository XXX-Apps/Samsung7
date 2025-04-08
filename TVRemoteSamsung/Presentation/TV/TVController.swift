import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities

final class TVController: CommonController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No connection".localized
        label.font = .font(weight: .medium, size: 16)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalDataBase.shared.isOnboardingShown = true
        
        configurNavigation(
            centerView: titleLabel
        )
        
        setupUI()
        setupSubscriptions()
    }
    
    private func setupUI() {
        
    }
    
    private func setupSubscriptions() {
        
    }
}
