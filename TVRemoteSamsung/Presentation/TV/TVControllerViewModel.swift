import UIKit
import PremiumManager
import Combine
import TVRemoteControl

// MARK: - ViewModel

enum CenterState: Int {
    case panel = 0
    case keyboard
    case pad
}

protocol TVControllerViewModelProtocol {
    var connectionStatusPublisher: AnyPublisher<Bool, Never> { get }
    var connectedDeviceName: String? { get }
    var isPremium: Bool { get }
    
    var onOpenDevices: (() -> Void)? { get set }
    var onOpenPaywall: (() -> Void)? { get set }
    var onOpenReview: (() -> Void)? { get set }
    var onOpenKeyboard: (() -> Void)? { get set }
    
    func sendCommand(_ command: SamsungTVRemoteCommand.Params.ControlKey)
    func sendText(_ text: String)
    func incrementUserActionCounter()
    func shouldShowFeedback() -> Bool
    func openKeyboard()
    func sendNumber(number: Int)
}

final class TVControllerViewModel: TVControllerViewModelProtocol {
    
    var onOpenReview: (() -> Void)?
    var onOpenDevices: (() -> Void)?
    var onOpenPaywall: (() -> Void)?
    var onOpenKeyboard: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let connectionManager = SamsungTVConnectionService.shared
    private let premiumManager = PremiumManager.shared
    private let localDatabase = LocalDataBase.shared
    
    // MARK: - Properties
    
    private(set) lazy var connectionStatusPublisher: AnyPublisher<Bool, Never> = connectionManager.connectionStatusPublisher
    private var cancellables = Set<AnyCancellable>()
    
    var connectedDeviceName: String? {
        connectionManager.connectedDevice?.name.decodingHTMLEntities()
    }
     
    var isPremium: Bool {
        premiumManager.isPremium.value
    }
    
    // MARK: - Public Methods
    
    func sendCommand(_ command: SamsungTVRemoteCommand.Params.ControlKey) {
        guard isPremium else {
            onOpenPaywall?()
            return
        }
        
        guard connectionManager.isConnected else {
            onOpenDevices?()
            return
        }
        
        incrementUserActionCounter()
        
        if shouldShowFeedback() {
            onOpenReview?()
        }
        
        connectionManager.sendCommand(command)
    }
    
    func sendText(_ text: String) {
        guard isPremium else {
            onOpenPaywall?()
            return
        }
        
        guard connectionManager.isConnected else {
            onOpenDevices?()
            return
        }
        
        incrementUserActionCounter()
        
        if shouldShowFeedback() {
            onOpenReview?()
        }
        
        connectionManager.sendText(textToSend: text)
    }
    
    func incrementUserActionCounter() {
        localDatabase.buttonsTapNumber += 1
    }
    
    func shouldShowFeedback() -> Bool {
        !localDatabase.wasRevviewScreen && localDatabase.buttonsTapNumber > 4
    }
    
    func openKeyboard() {
        guard isPremium else {
            onOpenPaywall?()
            return
        }
        
        guard connectionManager.isConnected else {
            onOpenDevices?()
            return
        }
        
        incrementUserActionCounter()
        
        if shouldShowFeedback() {
            onOpenReview?()
        }
        
        onOpenKeyboard?()
    }
    
    func sendNumber(number: Int) {
        
        guard isPremium else {
            onOpenPaywall?()
            return
        }
        
        guard connectionManager.isConnected else {
            onOpenDevices?()
            return
        }
        
        incrementUserActionCounter()
        
        if shouldShowFeedback() {
            onOpenReview?()
        }
        
        switch number {
         case 0:
             sendCommand(.number0)
         case 1:
             sendCommand(.number1)
         case 2:
             sendCommand(.number2)
         case 3:
             sendCommand(.number3)
         case 4:
             sendCommand(.number4)
         case 5:
             sendCommand(.number5)
         case 6:
             sendCommand(.number6)
         case 7:
             sendCommand(.number7)
         case 8:
             sendCommand(.number8)
         case 9:
             sendCommand(.number9)
         default:
             break
         }
    }
}
