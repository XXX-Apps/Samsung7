import UIKit
import SnapKit
import Utilities

// MARK: - Constants

private enum InputViewConstants {
    static let outerCornerRadius: CGFloat = 28
    static let innerCornerRadius: CGFloat = 23
    static let outerInsets: CGFloat = 24
    static let innerInsets: CGFloat = 28
    static let outerBackgroundColor = UIColor(hex: "31337C")
    static let innerBackgroundColor = UIColor(hex: "4A4CA9")
    static let textColor: UIColor = .white
    static let placeholderText = "Text here".localized
    static let font = UIFont.font(weight: .medium, size: 16)
}

// MARK: - KeyboardInputView

final class InputView: UIView {
    
    // MARK: - Callbacks
    
    var onTextChanged: ((String) -> Void)?
    var onReturnPressed: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = InputViewConstants.innerBackgroundColor
        view.layer.cornerRadius = InputViewConstants.innerCornerRadius
        return view
    }()
    
    lazy var inputField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: InputViewConstants.placeholderText,
            attributes: [.foregroundColor: InputViewConstants.textColor]
        )
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.font = InputViewConstants.font
        field.tintColor = InputViewConstants.textColor
        field.textColor = InputViewConstants.textColor
        field.returnKeyType = .done
        field.delegate = self
        field.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return field
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        configureView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        backgroundColor = InputViewConstants.outerBackgroundColor
        layer.cornerRadius = InputViewConstants.outerCornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(containerView)
        containerView.addSubview(inputField)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(InputViewConstants.outerInsets)
        }
        
        inputField.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(InputViewConstants.innerInsets)
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleTextChange(_ textField: UITextField) {
        onTextChanged?(textField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension InputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnPressed?()
        return true
    }
}
