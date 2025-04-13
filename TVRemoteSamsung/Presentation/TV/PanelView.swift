import UIKit
import SnapKit

final class PanelView: UIView {
    
    var upAction: (() -> Void)?
    var downAction: (() -> Void)?
    var leftAction: (() -> Void)?
    var rightAction: (() -> Void)?
    var okAction: (() -> Void)?
    var exitAction: (() -> Void)?
    var inputAction: (() -> Void)?
    var homeAction: (() -> Void)?
    var backAction: (() -> Void)?
        
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "centerPanelDisabled"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var centerView = UIView()
    
    private lazy var exitButton: UIButton = {
        let view = UIButton()
        view.setTitle("EXIT", for: .normal)
        view.titleLabel?.font = .font(weight: .regular, size: 18)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.addInnerShadow()
        })
        view.layer.cornerRadius = 36
        view.add(target: self, action: #selector(exitButtonAction))
        return view
    }()
    
    private lazy var inputButton: UIButton = {
        let view = UIButton()
        view.setTitle("INPUT", for: .normal)
        view.titleLabel?.font = .font(weight: .regular, size: 18)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.addInnerShadow()
        })
        view.layer.cornerRadius = 36
        view.add(target: self, action: #selector(inputButtonAction))
        return view
    }()
    
    private lazy var homeButton: UIButton = {
        let view = UIButton()
        view.setTitle("MENU", for: .normal)
        view.titleLabel?.font = .font(weight: .regular, size: 18)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.addInnerShadow()
        })
        view.layer.cornerRadius = 36
        view.add(target: self, action: #selector(homeButtonAction))
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let view = UIButton()
        view.setTitle("BACK", for: .normal)
        view.titleLabel?.font = .font(weight: .regular, size: 18)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.addInnerShadow()
        })
        view.layer.cornerRadius = 36
        view.add(target: self, action: #selector(backButtonAction))
        return view
    }()
    
    private lazy var centerButton: UIButton = createButton(action: #selector(centerButtonTapped))
    private lazy var upButton: UIButton = createButton(action: #selector(upButtonTapped))
    private lazy var downButton: UIButton = createButton(action: #selector(downButtonTapped))
    private lazy var leftButton: UIButton = createButton(action: #selector(leftButtonTapped))
    private lazy var rightButton: UIButton = createButton(action: #selector(rightButtonTapped))
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubviews(centerView, inputButton, homeButton, backButton, exitButton)
        centerView.addSubviews(imageView, centerButton, centerButton, upButton, downButton, leftButton, rightButton)
    }
    
    private func setupConstraints() {
        
        centerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(centerView.snp.height)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        centerButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.3)
        }
        
        upButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(centerButton.snp.top).offset(0)
            make.width.height.equalToSuperview().multipliedBy(0.3)
        }
        
        downButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(centerButton.snp.bottom).offset(0)
            make.width.height.equalToSuperview().multipliedBy(0.3)
        }
        
        leftButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(centerButton.snp.leading).offset(0)
            make.width.height.equalToSuperview().multipliedBy(0.3)
        }
        
        rightButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(centerButton.snp.trailing).offset(0)
            make.width.height.equalToSuperview().multipliedBy(0.3)
        }
        
        homeButton.snp.makeConstraints { make in
            make.height.width.equalTo(72)
            make.left.bottom.equalToSuperview().inset(10)
        }
        
        inputButton.snp.makeConstraints { make in
            make.height.width.equalTo(72)
            make.left.top.equalToSuperview().inset(10)
        }
        
        exitButton.snp.makeConstraints { make in
            make.height.width.equalTo(72)
            make.right.top.equalToSuperview().inset(10)
        }
        
        backButton.snp.makeConstraints { make in
            make.height.width.equalTo(72)
            make.right.bottom.equalToSuperview().inset(10)
        }
    }
    
    func updateState(isConnected: Bool) {
        imageView.image = UIImage(named: isConnected ? "centerPanel" : "centerPanelDisabled")
        homeButton.setTitleColor(isConnected ? .white : UIColor.init(hex: "7E94CE"), for: .normal)
        inputButton.setTitleColor(isConnected ? .white : UIColor.init(hex: "7E94CE"), for: .normal)
        exitButton.setTitleColor(isConnected ? .white : UIColor.init(hex: "7E94CE"), for: .normal)
        backButton.setTitleColor(isConnected ? .white : UIColor.init(hex: "7E94CE"), for: .normal)
    }
    
    private func createButton(action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Button Actions
    
    @objc private func centerButtonTapped() {
        okAction?()
    }
    
    @objc private func upButtonTapped() {
        upAction?()
    }
    
    @objc private func downButtonTapped() {
        downAction?()
    }
    
    @objc private func leftButtonTapped() {
        leftAction?()
    }
    
    @objc private func rightButtonTapped() {
        rightAction?()
    }
    
    @objc private func exitButtonAction() {
        exitAction?()
    }
    
    @objc private func inputButtonAction() {
        inputAction?()
    }
    
    @objc private func homeButtonAction() {
        homeAction?()
    }
    
    @objc private func backButtonAction() {
        backAction?()
    }
}
