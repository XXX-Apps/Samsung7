import UIKit
import SnapKit

// MARK: - Constants

private enum PanelConstants {
    static let buttonSize: CGFloat = 72
    static let buttonInsets: CGFloat = 10
    static let centerButtonMultiplier: CGFloat = 0.3
    static let centerViewInsets: CGFloat = 70
    static let buttonTitleFont = UIFont.font(weight: .regular, size: 18)
    static let activeColor: UIColor = .white
    static let inactiveColor = UIColor(hex: "7E94CE")
    static let buttonBackgroundColor = UIColor(hex: "31337C")
    static let activePanelImage = "centerPanel"
    static let inactivePanelImage = "centerPanelDisabled"
}

// MARK: - PanelView

final class ManipulatorView: UIView {
    
    // MARK: - Callbacks
    
    var upAction: (() -> Void)?
    var downAction: (() -> Void)?
    var leftAction: (() -> Void)?
    var rightAction: (() -> Void)?
    var okAction: (() -> Void)?
    var exitAction: (() -> Void)?
    var inputAction: (() -> Void)?
    var homeAction: (() -> Void)?
    var backAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var centerView = UIView()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: PanelConstants.inactivePanelImage)
        return imageView
    }()
    
    private lazy var centerButton = createTransparentButton(action: #selector(handleCenterButtonTap))
    private lazy var upButton = createTransparentButton(action: #selector(handleUpButtonTap))
    private lazy var downButton = createTransparentButton(action: #selector(handleDownButtonTap))
    private lazy var leftButton = createTransparentButton(action: #selector(handleLeftButtonTap))
    private lazy var rightButton = createTransparentButton(action: #selector(handleRightButtonTap))
    
    private lazy var exitButton = createActionButton(
        title: "EXIT",
        action: #selector(handleExitButtonTap)
    )
    
    private lazy var inputButton = createActionButton(
        title: "INPUT",
        action: #selector(handleInputButtonTap)
    )
    
    private lazy var homeButton = createActionButton(
        title: "MENU",
        action: #selector(handleHomeButtonTap)
    )
    
    private lazy var backButton = createActionButton(
        title: "BACK",
        action: #selector(handleBackButtonTap)
    )
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        configureView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateState(isConnected: Bool) {
        imageView.image = UIImage(named: isConnected ? PanelConstants.activePanelImage : PanelConstants.inactivePanelImage)
        let textColor = isConnected ? PanelConstants.activeColor : PanelConstants.inactiveColor
        
        [homeButton, inputButton, exitButton, backButton].forEach {
            $0.setTitleColor(textColor, for: .normal)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        backgroundColor = .clear
        addSubviews(centerView, inputButton, homeButton, backButton, exitButton)
        centerView.addSubviews(imageView, centerButton, upButton, downButton, leftButton, rightButton)
    }
    
    private func setupLayout() {
        centerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(PanelConstants.centerViewInsets)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(centerView.snp.height)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        centerButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().multipliedBy(PanelConstants.centerButtonMultiplier)
        }
        
        upButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(centerButton.snp.top)
            $0.width.height.equalToSuperview().multipliedBy(PanelConstants.centerButtonMultiplier)
        }
        
        downButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(centerButton.snp.bottom)
            $0.width.height.equalToSuperview().multipliedBy(PanelConstants.centerButtonMultiplier)
        }
        
        leftButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(centerButton.snp.leading)
            $0.width.height.equalToSuperview().multipliedBy(PanelConstants.centerButtonMultiplier)
        }
        
        rightButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(centerButton.snp.trailing)
            $0.width.height.equalToSuperview().multipliedBy(PanelConstants.centerButtonMultiplier)
        }
        
        homeButton.snp.makeConstraints {
            $0.size.equalTo(PanelConstants.buttonSize)
            $0.leading.bottom.equalToSuperview().inset(PanelConstants.buttonInsets)
        }
        
        inputButton.snp.makeConstraints {
            $0.size.equalTo(PanelConstants.buttonSize)
            $0.leading.top.equalToSuperview().inset(PanelConstants.buttonInsets)
        }
        
        exitButton.snp.makeConstraints {
            $0.size.equalTo(PanelConstants.buttonSize)
            $0.trailing.top.equalToSuperview().inset(PanelConstants.buttonInsets)
        }
        
        backButton.snp.makeConstraints {
            $0.size.equalTo(PanelConstants.buttonSize)
            $0.trailing.bottom.equalToSuperview().inset(PanelConstants.buttonInsets)
        }
    }
    
    private func createActionButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = PanelConstants.buttonTitleFont
        button.backgroundColor = PanelConstants.buttonBackgroundColor
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            button.layer.cornerRadius = button.frame.height / 2
            button.addCircleInnerShadow()
        }
        
        return button
    }
    
    private func createTransparentButton(action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func handleCenterButtonTap() { okAction?() }
    @objc private func handleUpButtonTap() { upAction?() }
    @objc private func handleDownButtonTap() { downAction?() }
    @objc private func handleLeftButtonTap() { leftAction?() }
    @objc private func handleRightButtonTap() { rightAction?() }
    @objc private func handleExitButtonTap() { exitAction?() }
    @objc private func handleInputButtonTap() { inputAction?() }
    @objc private func handleHomeButtonTap() { homeAction?() }
    @objc private func handleBackButtonTap() { backAction?() }
}
