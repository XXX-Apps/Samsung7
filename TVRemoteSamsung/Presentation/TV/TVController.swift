import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import TVRemoteControl

final class TVController: CommonController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let mainColor = UIColor(hex: "31337C")
        static let blurColor = UIColor(hex: "171313")
        
        enum Layout {
            static let defaultInset: CGFloat = 24
            static let buttonSize: CGFloat = 50
            static let volumeButtonWidth: CGFloat = UIScreen.isLittleDevice ? 60 : 72
            static let stackViewSpacing: CGFloat = 19
            static let volumeStackViewSpacing: CGFloat = 11
            static let inputContainerHeight: CGFloat = 108
            static let padCornerRadius: CGFloat = 44
            static let smallDeviceTopOffset: CGFloat = 23
            static let regularDeviceTopOffset: CGFloat = 33
            static let smallDeviceBottomInset: CGFloat = -37
            static let regularDeviceBottomInset: CGFloat = -47
            static let smallDeviceButtonHeight: CGFloat = 66
            static let regularDeviceButtonHeight: CGFloat = 72
            static let safeAreaBottomInset: CGFloat = 94
            static let stackViewBottomOffset: CGFloat = -20
            static let pageControlBottomInset: CGFloat = UIScreen.isLittleDevice ? -16 : -26
            static let padTopInset: CGFloat = 30
            static let padBottomInset: CGFloat = 40
        }
        
        enum Blur {
            static let radius: CGFloat = 3
            static let tintAlpha: CGFloat = 0.3
        }
        
        enum Text {
            static let noConnection = "No connection".localized
            static let volTitle = "VOL"
            static let padTitle = "Swipe or tap in this field to use".localized
        }
        
        enum Images {
            static let connect = "connect"
            static let power = "power"
            static let powerRed = "powerRed"
            static let search = "search"
            static let playBack = "playBack"
            static let play = "play"
            static let playForward = "playForward"
            static let mute = "mute"
            static let volUp = "volUp"
            static let volDown = "volDown"
        }
        
        enum Fonts {
            static let title = UIFont.font(weight: .medium, size: 18)
            static let padTitle = UIFont.font(weight: .regular, size: 16)
            static let volTitle = UIFont.font(weight: .regular, size: 18)
        }
        
        enum Delays {
            static let shadowDelay: DispatchTime = .now() + 0.1
            static let initialStateDelay: DispatchTime = .now() + 0.1
        }
    }
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: TVControllerViewModelProtocol = TVControllerViewModel()
    private let disposeBag = DisposeBag()
    private let centerView = UIView()
    
    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.numberOfPages = 3
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.noConnection
        label.font = Constants.Fonts.title
        return label
    }()
    
    private lazy var blurView = CustomBlurEffectView().apply {
        $0.blurRadius = Constants.Blur.radius
        $0.colorTint = Constants.blurColor
        $0.colorTintAlpha = Constants.Blur.tintAlpha
        $0.isHidden = true
    }
    
    private lazy var inputContainer = InputView().apply {
        $0.isHidden = true
        $0.onTextChanged = { [weak self] text in self?.viewModel.sendText(text) }
        $0.onReturnPressed = { [weak self] in self?.dismissKeyboard() }
    }
    
    private lazy var padView: UIButton = {
        let view = UIButton()
        view.setTitle(Constants.Text.padTitle, for: .normal)
        view.tag = 8
        view.titleLabel?.font = Constants.Fonts.padTitle
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.Layout.padCornerRadius
        view.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: Constants.Delays.shadowDelay) {
            view.addCircleInnerShadow()
        }
        
        [UISwipeGestureRecognizer.Direction.up, .down, .left, .right].forEach { direction in
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            gesture.direction = direction
            view.addGestureRecognizer(gesture)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(okAction)))
        return view
    }()
    
    private lazy var keyboardView = KeyboardView().apply {
        $0.onNumberTapped = { [weak self] number in self?.numberAction(number: number) }
    }
    
    private lazy var panelView = ManipulatorView().apply {
        $0.downAction = { [weak self] in self?.downAction() }
        $0.upAction = { [weak self] in self?.upAction() }
        $0.leftAction = { [weak self] in self?.leftAction() }
        $0.rightAction = { [weak self] in self?.rightAction() }
        $0.okAction = { [weak self] in self?.okAction() }
        $0.homeAction = { [weak self] in self?.homeAction() }
        $0.inputAction = { [weak self] in self?.inputAction() }
        $0.exitAction = { [weak self] in self?.exitAction() }
        $0.backAction = { [weak self] in self?.backAction() }
    }
    
    private var currentState: CenterState = .panel {
        didSet {
            updateCenterViewState()
        }
    }
    
    private lazy var connectButton = createCircleButton(imageName: Constants.Images.connect, selector: #selector(connectAction))
    private lazy var powerButton = createCircleButton(imageName: Constants.Images.power, selector: #selector(powerAction))
    private lazy var searchButton = createCircleButton(imageName: Constants.Images.search, selector: #selector(searchAction))
    private lazy var playBackButton = createCircleButton(imageName: Constants.Images.playBack, selector: #selector(playBackAction))
    private lazy var playButton = createCircleButton(imageName: Constants.Images.play, selector: #selector(playAction))
    private lazy var playForwardButton = createCircleButton(imageName: Constants.Images.playForward, selector: #selector(playForwardAction))
    private lazy var muteButton = createCircleButton(imageName: Constants.Images.mute, selector: #selector(muteAction))
    
    private lazy var imageButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [searchButton, playBackButton, playButton, playForwardButton])
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    private lazy var volumeView: UIButton = {
        let view = UIButton()
        view.setTitle(Constants.Text.volTitle, for: .normal)
        view.titleLabel?.font = Constants.Fonts.volTitle
        view.backgroundColor = Constants.mainColor
        
        DispatchQueue.main.asyncAfter(deadline: Constants.Delays.shadowDelay) {
            view.layer.cornerRadius = view.frame.height / 2
            view.addCircleInnerShadow()
        }
        
        view.addSubviews(volumeUpButton, volumeDownButton)
        
        volumeUpButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Constants.Layout.volumeButtonWidth)
        }
        
        volumeDownButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Constants.Layout.volumeButtonWidth)
        }
        
        return view
    }()
    
    private lazy var volumeUpButton: UIButton = {
        createImageButton(imageName: Constants.Images.volUp, selector: #selector(volumeUpAction))
    }()
    
    private lazy var volumeDownButton: UIButton = {
        createImageButton(imageName: Constants.Images.volDown, selector: #selector(volumeDownAction))
    }()
    
    private lazy var volumeButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [muteButton, volumeView])
        view.axis = .horizontal
        view.spacing = (UIScreen.main.bounds.width - 48 - (72 * 4)) / 3
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalDataBase.shared.needSkipOnboarding = true
                
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
        
        DispatchQueue.main.asyncAfter(deadline: Constants.Delays.initialStateDelay) {
            self.currentState = .panel
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        connectButton.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.Layout.buttonSize)
        }
        
        powerButton.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.Layout.buttonSize)
        }
        
        view.addSubviews(
            imageButtonsStackView,
            volumeButtonsStackView,
            centerView,
            pageControl
        )
        
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.Layout.defaultInset)
            make.top.equalTo(topView.snp.bottom).offset(
                UIScreen.isLittleDevice ?
                Constants.Layout.smallDeviceTopOffset :
                Constants.Layout.regularDeviceTopOffset
            )
            make.bottom.equalTo(imageButtonsStackView.snp.top).inset(
                UIScreen.isLittleDevice ?
                Constants.Layout.smallDeviceBottomInset :
                Constants.Layout.regularDeviceBottomInset
            )
        }
        
        volumeButtonsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.Layout.defaultInset)
            make.height.equalTo(
                UIScreen.isLittleDevice ?
                Constants.Layout.smallDeviceButtonHeight :
                Constants.Layout.regularDeviceButtonHeight
            )
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.Layout.safeAreaBottomInset)
        }
        
        imageButtonsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.Layout.defaultInset)
            make.height.equalTo(
                UIScreen.isLittleDevice ?
                Constants.Layout.smallDeviceButtonHeight :
                Constants.Layout.regularDeviceButtonHeight
            )
            make.bottom.equalTo(volumeButtonsStackView.snp.top).offset(Constants.Layout.stackViewBottomOffset)
        }
        
        muteButton.snp.makeConstraints { make in
            make.width.equalTo(searchButton.snp.width)
        }
        
        centerView.addSubviews(panelView, keyboardView, padView)
        panelView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        keyboardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        padView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(Constants.Layout.padTopInset)
            make.bottom.equalToSuperview().inset(Constants.Layout.padBottomInset)
        }
        
        view.addSubviews(blurView)
        blurView.addSubviews(inputContainer)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        inputContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(Constants.Layout.inputContainerHeight)
            make.bottom.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(imageButtonsStackView.snp.top).inset(Constants.Layout.pageControlBottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubscriptions() {
        viewModel.connectionStatusPublisher
            .sink { [weak self] isConnected in
                DispatchQueue.main.async {
                    self?.panelView.updateState(isConnected: isConnected)
                    self?.titleLabel.text = isConnected ? self?.viewModel.connectedDeviceName : "No connection".localized
                    self?.powerButton.setImage(UIImage(named: isConnected ? "powerRed" : "power"), for: .normal)
                }
            }
            .store(in: &cancellables)
        
        viewModel.onOpenReview = { [weak self] in self?.presentCrossDissolve(vc: ReviewController()) }
        viewModel.onOpenKeyboard = { [weak self] in self?.openKeyboard() }
        viewModel.onOpenPaywall = { [weak self] in self?.openPaywall() }
        viewModel.onOpenDevices = { [weak self] in self?.connectAction() }
    }
    
    private func setupSwipeGestures() {
        [UISwipeGestureRecognizer.Direction.left, .right].forEach { direction in
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            gesture.direction = direction
            centerView.addGestureRecognizer(gesture)
        }
        centerView.isUserInteractionEnabled = true
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
    
    // MARK: - Helper Methods
    
    private func createCircleButton(imageName: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: imageName), for: .normal)
        button.backgroundColor = .init(hex: "31337C")
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.width.equalTo(button.snp.height)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            button.layer.cornerRadius = button.frame.height / 2
            button.addCircleInnerShadow()
        }
        
        return button
    }
    
    private func createImageButton(imageName: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    private func updateCenterViewState() {
        panelView.isHidden = currentState != .panel
        keyboardView.isHidden = currentState != .keyboard
        padView.isHidden = currentState != .pad
        pageControl.currentPage = currentState.rawValue
    }
    
    private func switchToNextState() {
        currentState = currentState.next()
    }
    
    private func switchToPreviousState() {
        currentState = currentState.previous()
    }
    
    private func openKeyboard() {
        blurView.isHidden = false
        inputContainer.isHidden = false
        inputContainer.inputField.becomeFirstResponder()
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Action Methods
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up: viewModel.sendCommand(.up)
        case .down: viewModel.sendCommand(.down)
        case .left: switchToNextState()
        case .right: switchToPreviousState()
        default: break
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardFrame.height)
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
    
    @objc private func connectAction() { generateHapticFeedback(); present(vc: DevicesController()) }
    @objc private func powerAction() { generateHapticFeedback(); viewModel.sendCommand(.powerToggle) }
    @objc private func exitAction() { generateHapticFeedback(); viewModel.sendCommand(.exit) }
    @objc private func inputAction() { generateHapticFeedback(); viewModel.openKeyboard() }
    @objc private func homeAction() { generateHapticFeedback(); viewModel.sendCommand(.home) }
    @objc private func backAction() { generateHapticFeedback(); viewModel.sendCommand(.returnKey) }
    @objc private func searchAction() { generateHapticFeedback(); viewModel.sendCommand(.contents) }
    @objc private func playBackAction() { generateHapticFeedback(); viewModel.sendCommand(.rewind) }
    @objc private func playAction() { generateHapticFeedback(); viewModel.sendCommand(.enter) }
    @objc private func playForwardAction() { generateHapticFeedback(); viewModel.sendCommand(.fastForward) }
    @objc private func muteAction() { generateHapticFeedback(); viewModel.sendCommand(.mute) }
    @objc private func volumeUpAction() { generateHapticFeedback(); viewModel.sendCommand(.volumeUp) }
    @objc private func volumeDownAction() { generateHapticFeedback(); viewModel.sendCommand(.volumeDown) }
    @objc private func panelAction() { generateHapticFeedback(); currentState = .panel }
    @objc private func keyboardAction() { generateHapticFeedback(); currentState = .keyboard }
    @objc private func padAction() { generateHapticFeedback(); currentState = .pad }
    @objc private func upAction() { generateHapticFeedback(); viewModel.sendCommand(.up) }
    @objc private func downAction() { generateHapticFeedback(); viewModel.sendCommand(.down) }
    @objc private func leftAction() { generateHapticFeedback(); viewModel.sendCommand(.left) }
    @objc private func rightAction() { generateHapticFeedback(); viewModel.sendCommand(.right) }
    @objc private func okAction() { generateHapticFeedback(); viewModel.sendCommand(.enter) }
    
    @objc private func numberAction(number: Int) {
        generateHapticFeedback()
        viewModel.sendNumber(number: number)
    }
    
    private func openPaywall() {
        guard !PremiumManager.shared.isPremium.value else {
            return
        }
        
        let vc = PaywallViewController(
            interactor: OnboardingInteractor(
                coordinator: OnboardingCoordinator(window: nil)
            )
        )
        present(vc: vc)
    }
}

// MARK: - CenterState Extension

private extension CenterState {
    func next() -> CenterState {
        switch self {
        case .panel: return .keyboard
        case .keyboard: return .pad
        case .pad: return .panel
        }
    }
    
    func previous() -> CenterState {
        switch self {
        case .panel: return .pad
        case .keyboard: return .panel
        case .pad: return .keyboard
        }
    }
}
