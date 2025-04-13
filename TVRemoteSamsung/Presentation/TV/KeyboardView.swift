import UIKit
import SnapKit
import Utilities

// MARK: - Constants

private enum KeyboardConstants {
    static let buttonSize: CGFloat = 72
    static let buttonSpacing: CGFloat = 20.5
    static let rowSpacing: CGFloat = 12
    static let buttonCornerRadiusMultiplier: CGFloat = 0.5
    static let buttonBackgroundColor = UIColor(hex: "31337C")
    static let buttonFont = UIFont.font(weight: .regular, size: 24)
    static let minHeightForStandardLayout: CGFloat = (72 * 4) + 36
}

// MARK: - KeyboardView

final class KeyboardView: UIView {
    
    // MARK: - Properties
    
    var onNumberTapped: ((Int) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            createNumberRow(numbers: [1, 2, 3]),
            createNumberRow(numbers: [4, 5, 6]),
            createNumberRow(numbers: [7, 8, 9]),
            createZeroButtonRow()
        ])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = KeyboardConstants.rowSpacing
        return stack
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    private func createNumberRow(numbers: [Int]) -> UIStackView {
        let buttons = numbers.map { createNumberButton(number: $0) }
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = KeyboardConstants.buttonSpacing
        stack.distribution = .fillEqually
        return stack
    }
    
    private func createZeroButtonRow() -> UIStackView {
        let zeroButton = createNumberButton(number: 0)
        let stack = UIStackView(arrangedSubviews: [UIView(), zeroButton, UIView()])
        stack.axis = .horizontal
        stack.spacing = KeyboardConstants.buttonSpacing
        stack.distribution = .fillEqually
        return stack
    }
    
    private func createNumberButton(number: Int) -> UIButton {
        let button = UIButton()
        button.setTitle("\(number)", for: .normal)
        button.tag = number
        button.titleLabel?.font = KeyboardConstants.buttonFont
        button.backgroundColor = KeyboardConstants.buttonBackgroundColor
        button.addTarget(self, action: #selector(handleNumberTap(_:)), for: .touchUpInside)
        
        button.snp.makeConstraints {
            $0.width.equalTo(KeyboardConstants.buttonSize)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            button.layer.cornerRadius = button.bounds.height * KeyboardConstants.buttonCornerRadiusMultiplier
            button.addInnerShadow()
        }
        
        return button
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.height != .zero else { return }
        
        let useCompactLayout = bounds.height < KeyboardConstants.minHeightForStandardLayout
        let buttonHeight = useCompactLayout ? (bounds.height - 100) / 4 : KeyboardConstants.buttonSize
        
        mainStackView.arrangedSubviews.forEach { row in
            guard let stackRow = row as? UIStackView else { return }
            stackRow.snp.updateConstraints {
                $0.height.equalTo(buttonHeight)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleNumberTap(_ sender: UIButton) {
        onNumberTapped?(sender.tag)
    }
}
