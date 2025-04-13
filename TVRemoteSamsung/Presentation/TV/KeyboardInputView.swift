import UIKit
import SnapKit
import Utilities

final class KeyboardInputView: UIView, UITextFieldDelegate {
    
    var onTextChanged: ((String) -> Void)?
    var onReturnPressed: (() -> Void)?
    
    private let containerView = UIView().apply {
        $0.backgroundColor = .init(hex: "4A4CA9")
        $0.layer.cornerRadius = 23
    }
    
    lazy var inputField = UITextField().apply {
        $0.attributedPlaceholder = NSAttributedString(
            string: "Text here".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        $0.borderStyle = .none
        $0.backgroundColor = .clear
        $0.font = .font(weight: .medium, size: 16)
        $0.delegate = self
        $0.tintColor = .white
        $0.textColor = .white
        $0.delegate = self
        $0.returnKeyType = .done
        $0.addTarget(self, action: #selector(textFieldUpdate(_:)), for: .editingChanged)
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        backgroundColor = .init(hex: "31337C")
        layer.cornerRadius = 28
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubviews(containerView)
        
        containerView.addSubviews(inputField)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
        
        inputField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.right.equalToSuperview().inset(28)
            make.top.bottom.equalToSuperview()
        }
    }
    
    @objc private func textFieldUpdate(_ textField: UITextField) {
        onTextChanged?(textField.text ?? "")
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnPressed?()
        return true
    }
}

