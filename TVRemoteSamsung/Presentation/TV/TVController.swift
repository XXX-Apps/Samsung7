import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import TVRemoteControl

enum CenterState {
    case panel
    case keyboard
    case pad
}

final class TVController: CommonController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let connectionManager = SamsungTVConnectionService.shared
    
    private let disposeBag = DisposeBag()
    
    private let centerView: UIView = UIView()
    
    private let pageControl: UIPageControl = {
        let view = UIPageControl()
        view.numberOfPages = 3
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No connection".localized
        label.font = .font(weight: .medium, size: 16)
        return label
    }()
    
    private let blurView = CustomBlurEffectView().apply {
        $0.blurRadius = 3
        $0.colorTint = .init(hex: "171313")
        $0.colorTintAlpha = 0.3
        $0.isHidden = true
    }
    
    private lazy var inputContainer = InputView().apply {
        $0.isHidden = true
        $0.onTextChanged = { [weak self] text in
            guard let self else { return }
            
            guard PremiumManager.shared.isPremium.value else {
                openPaywall()
                return
            }
            
            guard connectionManager.isConnected == true else {
                connectAction()
                return
            }
            
            connectionManager.sendText(textToSend: text)
        }
        $0.onReturnPressed = { [weak self] in
            self?.dismissKeyboard()
        }
    }
    
    private lazy var padView: UIButton = {
        
        let view = UIButton()
        view.setTitle("Swipe or tap in this field to use", for: .normal)
        view.tag = 8
        view.titleLabel?.font = .font(weight: .regular, size: 16)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.addInnerShadow()
        })
        view.layer.cornerRadius = 44
        
        view.isHidden = true
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(_:)))
        swipeUpGesture.direction = .up
        view.addGestureRecognizer(swipeUpGesture)

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(okAction))
        view.addGestureRecognizer(tapRecognizer)
        
        return view
    }()
    
    private lazy var keyboardView = KeyboardView().apply {
        $0.onNumberTapped = { [weak self] number in
            self?.numberAction(number: number)
        }
    }
    
    private lazy var panelView = PanelView().apply {
        $0.downAction = { [weak self] in
            self?.downAction()
        }
        $0.upAction = { [weak self] in
            self?.upAction()
        }
        $0.leftAction = { [weak self] in
            self?.leftAction()
        }
        $0.rightAction = { [weak self] in
            self?.rightAction()
        }
        $0.okAction = { [weak self] in
            self?.okAction()
        }
        $0.homeAction = { [weak self] in
            self?.homeAction()
        }
        $0.inputAction = { [weak self] in
            self?.inputAction()
        }
        $0.exitAction = { [weak self] in
            self?.exitAction()
        }
        $0.backAction = { [weak self] in
            self?.backAction()
        }
    }
    
    private var currentState: CenterState = .panel {
        didSet {
            switch currentState {
            case .panel:
                panelView.isHidden = false
                keyboardView.isHidden = true
                padView.isHidden = true
                pageControl.currentPage = 0
            case .keyboard:
                panelView.isHidden = true
                keyboardView.isHidden = false
                padView.isHidden = true
                pageControl.currentPage = 1
            case .pad:
                panelView.isHidden = true
                keyboardView.isHidden = true
                padView.isHidden = false
                pageControl.currentPage = 2
            }
        }
    }
    
    private lazy var connectButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "connect"), for: .normal)
        view.add(target: self, action: #selector(connectAction))
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        return view
    }()
    
    private lazy var powerButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "power"), for: .normal)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.add(target: self, action: #selector(powerAction))
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "search"), for: .normal)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.add(target: self, action: #selector(searchAction))
        return view
    }()
    
    private lazy var playBackButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "playBack"), for: .normal)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.add(target: self, action: #selector(playBackAction))
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "play"), for: .normal)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.add(target: self, action: #selector(playAction))
        return view
    }()
    
    private lazy var playForwardButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "playForward"), for: .normal)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.add(target: self, action: #selector(playForwardAction))
        return view
    }()

    private lazy var imageButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [searchButton, playBackButton, playButton, playForwardButton])
        view.axis = .horizontal
        view.spacing = 19
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var muteButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "mute"), for: .normal)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        view.add(target: self, action: #selector(muteAction))
        return view
    }()
    
    private lazy var volumeView: UIButton = {
        let view = UIButton()
        view.setTitle("VOL", for: .normal)
        view.titleLabel?.font = .font(weight: .regular, size: 18)
        view.backgroundColor = .init(hex: "31337C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            view.layer.cornerRadius = view.frame.height / 2
            view.addInnerShadow()
        })
        
        view.addSubviews(volumeUpButton, volumeDownButton)
        
        volumeUpButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.isLittleDevice ? 60 : 72)
        }
        
        volumeDownButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.isLittleDevice ? 60 : 72)
        }
        
        return view
    }()
    
    private lazy var volumeUpButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "volUp"), for: .normal)
        view.addTarget(self, action: #selector(volumeUpAction), for: .touchUpInside)
        return view
    }()
    
    private lazy var volumeDownButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "volDown"), for: .normal)
        view.addTarget(self, action: #selector(volumeDownAction), for: .touchUpInside)
        return view
    }()
    
    private lazy var volumeButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [muteButton, volumeView])
        view.axis = .horizontal
        view.spacing = 11
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalDataBase.shared.isOnboardingShown = true
                
        configurNavigation(
            leftView: powerButton,
            centerView: titleLabel,
            rightView: connectButton
        )
        
        setupUI()
        setupSubscriptions()
        setupGestureRecognizers()
        setupKeyboardNotifications()
        
        setupSwipeGestures()
    }
    
    private func setupUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.currentState = .panel
        }
        
        connectButton.snp.makeConstraints { make in
            make.height.width.equalTo(50)
        }
        
        powerButton.snp.makeConstraints { make in
            make.height.width.equalTo(50)
        }
        
        view.addSubviews(
            imageButtonsStackView,
            volumeButtonsStackView,
            centerView,
            pageControl
        )
        
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(topView.snp.bottom).offset(UIScreen.isLittleDevice ? 23 : 33)
            make.bottom.equalTo(imageButtonsStackView.snp.top).inset(UIScreen.isLittleDevice ? -37 : -47)
        }
        
        volumeButtonsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(UIScreen.isLittleDevice ? 66 : 72)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(94)
        }
        
        imageButtonsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(UIScreen.isLittleDevice ? 66 : 72)
            make.bottom.equalTo(volumeButtonsStackView.snp.top).offset(-20)
        }
        
        muteButton.snp.makeConstraints { make in
            make.width.equalTo(searchButton.snp.width)
        }
        
        centerView.addSubviews(panelView, keyboardView, padView)
        panelView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        keyboardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        padView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(40)
        }
        
        view.addSubviews(blurView)
        blurView.addSubviews(inputContainer)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        inputContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(108)
            make.bottom.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(imageButtonsStackView.snp.top).inset(-26)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubscriptions() {
        connectionManager
            .connectionStatusPublisher
            .sink { isConnected in
                DispatchQueue.main.async {
                    self.panelView.updateState(isConnected: isConnected)
                    self.titleLabel.text = isConnected ? self.connectionManager.connectedDevice?.name.decodingHTMLEntities() : "No connection".localized
                    self.powerButton.setImage(UIImage(named: isConnected ? "powerRed" : "power"), for: .normal)
                }
            }
            .store(in: &cancellables)
    }
}

extension TVController {
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        centerView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        centerView.addGestureRecognizer(swipeRight)
        
        centerView.isUserInteractionEnabled = true
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            switchToNextState()
        case .right:
            switchToPreviousState()
        default:
            break
        }
    }
    
    private func switchToNextState() {
        switch currentState {
        case .panel:
            currentState = .keyboard
        case .keyboard:
            currentState = .pad
        case .pad:
            currentState = .panel
        }
    }
    
    private func switchToPreviousState() {
        switch currentState {
        case .panel:
            currentState = .pad
        case .keyboard:
            currentState = .panel
        case .pad:
            currentState = .keyboard
        }
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height

        inputContainer.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    @objc private func dismissKeyboard() {
        inputContainer.isHidden = true
        blurView.isHidden = true
        view.endEditing(true)
    }
    
    private func openKeyboard() {
        blurView.isHidden = false
        inputContainer.isHidden = false
        inputContainer.inputField.becomeFirstResponder()
    }
    
    @objc private func connectAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        present(vc: DevicesController())
    }
    
    @objc private func powerAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.powerToggle)
    }
    
    @objc private func exitAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.exit)
    }
    
    @objc private func inputAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        openKeyboard()
    }
    
    @objc private func homeAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.home)
    }
    
    @objc private func backAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.returnKey)
    }
    
    @objc private func searchAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.contents)
    }
    
    @objc private func playBackAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.rewind)
    }
    
    @objc private func playAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.enter)
    }
    
    @objc private func playForwardAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.fastForward)
    }
    
    @objc private func muteAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.mute)
    }
    
    @objc private func volumeUpAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.volumeUp)
    }
    
    @objc private func volumeDownAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.volumeDown)
    }
    
    @objc private func panelAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        currentState = .panel
    }
    
    @objc private func keyboardAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        currentState = .keyboard
    }
    
    @objc private func padAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        currentState = .pad
    }
    
    @objc private func upAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.up)
    }
    
    @objc private func downAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.down)
    }
    
    @objc private func leftAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.left)
    }
    
    @objc private func rightAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.right)
    }
    
    @objc private func okAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.enter)
    }
    
    @objc private func numberAction(number: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        switch number {
        case 0:
            connectionManager.sendCommand(.number0)
        case 1:
            connectionManager.sendCommand(.number1)
        case 2:
            connectionManager.sendCommand(.number2)
        case 3:
            connectionManager.sendCommand(.number3)
        case 4:
            connectionManager.sendCommand(.number4)
        case 5:
            connectionManager.sendCommand(.number5)
        case 6:
            connectionManager.sendCommand(.number6)
        case 7:
            connectionManager.sendCommand(.number7)
        case 8:
            connectionManager.sendCommand(.number8)
        case 9:
            connectionManager.sendCommand(.number9)
        default:
            break
        }
    }
    
    @objc func handleSwipeUp(_ gesture: UISwipeGestureRecognizer) {
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.up)
    }

    @objc func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.down)
    }

    @objc func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.left)
    }

    @objc func handleSwipeRight(_ gesture: UISwipeGestureRecognizer) {
        
        guard PremiumManager.shared.isPremium.value else {
            openPaywall()
            return
        }
        
        checkFeedback()
        
        guard connectionManager.isConnected else {
            connectAction()
            return
        }
        
        connectionManager.sendCommand(.right)
    }
    
    private func checkFeedback() {
        
        LocalDataBase.shared.userActionCounter += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !LocalDataBase.shared.isFeedbackShown, LocalDataBase.shared.userActionCounter > 4 {
                UIApplication.topViewController()?.presentCrossDissolve(vc: ReviewController())
            }
        }
    }
    
    private func openPaywall() {
        let vc = Paywall()
        vc.isFromOnboarding = false
        present(vc: vc)
    }
}
