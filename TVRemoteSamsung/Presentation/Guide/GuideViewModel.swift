import UIKit
import Utilities

struct GuideModel {
    let image: UIImage?
    let title: String
    let subtitle: String
}

final class GuideViewModel {
    
    let models: [GuideModel] = [
        .init(
            image: UIImage(named: "wifi"),
            title: "Wi-Fi".localized,
            subtitle: "Your phone and TV device both need to be connected to the same Wi-Fi network".localized
        ),
        .init(
            image: UIImage(named: "localNetwork"),
            title: "Local network ".localized,
            subtitle: "Ensure the app is allowed to access the local network by going to “Settings > Privacy > Local Network” and checking that it's turned on".localized
        ),
        .init(
            image: UIImage(named: "powerCycling"),
            title: "Power cycling".localized,
            subtitle: "If your TV is not detected, consider restarting (power cycling) the device before attempting again".localized
        ),
        .init(
            image: UIImage(named: "restart"),
            title: "Restart".localized,
            subtitle: "Exit and restart the app".localized
        ),
        .init(
            image: UIImage(named: "router"),
            title: "Router".localized,
            subtitle: "Restart your Wi-Fi router".localized
        )
    ]
}
