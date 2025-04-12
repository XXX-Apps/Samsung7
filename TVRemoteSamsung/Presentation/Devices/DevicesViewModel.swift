import Foundation
import TVRemoteControl
import TVCommanderKit

final class DevicesViewModel {
    
    var devices: [SamsungTVModel] = []
    
    let tvSearcher = TVSearcher()
    var samsungTV: SamsungTV?
    let connectionManager = SamsungTVConnectionService.shared
        
    private var connectedDevice: SamsungTVModel?
    
    var devicesNotFound = false
    
    var onUpdate: (() -> Void)?
    var onConnectionError: (() -> Void)?
    var onConnected: (() -> Void)?
    var onConnecting: (() -> Void)?
    var onNotFound: (() -> Void)?
    
    init() {
        tvSearcher.addSearchObserver(self)
        tvSearcher.startSearch()
    }
    
    func reload() {
        devicesNotFound = false
        devices.removeAll()
        onUpdate?()
        tvSearcher.startSearch()
    }
    
    func connect(tv: SamsungTVModel) {
        connectedDevice = tv
        samsungTV = try? SamsungTV(tv: tv, appName: Config.appName)
        samsungTV?.delegate = self
        samsungTV?.connectToTV()
        onConnecting?()
    }
    
    func cancelConnection() {
        samsungTV?.disconnectFromTV()
    }
}

extension DevicesViewModel: TVSearchObserving {

    func tvSearchDidStart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.tvSearcher.stopSearch()
            if self.devices.isEmpty {
                self.devicesNotFound = true
                self.onNotFound?()
            } else {
                self.onUpdate?()
            }
        }
    }
    
    func tvSearchDidStop() {}
    
    func tvSearchDidFindTV(_ tv: TVCommanderKit.TV) {
        
        let tv = SamsungTVModel.init(
            device: SamsungTVModel.Device.init(
                countryCode: tv.device?.countryCode,
                deviceDescription: tv.device?.deviceDescription,
                developerIp: tv.device?.developerIp,
                developerMode: tv.device?.developerMode,
                duid: tv.device?.duid,
                firmwareVersion: tv.device?.firmwareVersion,
                frameTvSupport: tv.device?.frameTvSupport,
                gamePadSupport: tv.device?.gamePadSupport,
                id: tv.device?.id,
                imeSyncedSupport: tv.device?.imeSyncedSupport,
                ip: tv.device?.ip,
                language: tv.device?.language,
                model: tv.device?.model,
                modelName: tv.device?.modelName,
                name: tv.device?.name,
                networkType: tv.device?.networkType,
                os: tv.device?.os,
                powerState: tv.device?.powerState,
                resolution: tv.device?.resolution,
                smartHubAgreement: tv.device?.smartHubAgreement,
                ssid: tv.device?.ssid,
                tokenAuthSupport: tv.device?.tokenAuthSupport ?? "",
                type: tv.device?.type,
                udn: tv.device?.udn,
                voiceSupport: tv.device?.voiceSupport,
                wallScreenRatio: tv.device?.wallScreenRatio,
                wallService: tv.device?.wallService,
                wifiMac: tv.device?.wifiMac ?? ""
            ),
            id: tv.id,
            isSupport: tv.isSupport,
            name: tv.name,
            remote: tv.remote,
            type: tv.type,
            uri: tv.uri,
            version: tv.version
        )
        
        
        devices.append(tv)
        devicesNotFound = false
        onUpdate?()
    }
    
    func tvSearchDidLoseTV(_ tv: TVCommanderKit.TV) {}
}

extension DevicesViewModel: SamsungTVDelegate {
    
    func samsungTVDidConnect(_ samsungTV: SamsungTV) {}
    
    func samsungTVDidDisconnect(_ samsungTV: SamsungTV) {}
    
    func samsungTV(_ samsungTV: SamsungTV, didUpdateAuthState authStatus: SamsungTVAuthStatus) {
        switch authStatus {
        case .allowed:
            if let connectedDevice {
                connectionManager.connect(to: connectedDevice, appName: Config.appName, commander: samsungTV)
                onConnected?()
                onUpdate?()
            }
        case .denied, .none:
            onConnectionError?()
        }
    }
    
    func samsungTV(_ samsungTV: SamsungTV, didWriteRemoteCommand command: SamsungTVRemoteCommand) {}
    
    func samsungTV(_ samsungTV: SamsungTV, didEncounterError error: SamsungTVError) {}
}
