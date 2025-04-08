import CustomTabBar
import UIKit
import Utilities

final class TabBarConfigurator {
    static func main() -> TabBarController {
        let configuration = TabBarConfiguration(
            cornerRadius: 0,
            stackViewSpacing: 0,
            tabBarHeight: UIScreen.isLittleDevice ? 83 : 103,
            tabBarItems: [
                .init(
                    title: "Controller".localized,
                    image: UIImage(named: "remoteTab")
                ),
                .init(
                    title: "Applications".localized,
                    image: UIImage(named: "remoteTab")
                ),
                .init(
                    title: "Options".localized,
                    image: UIImage(named: "remoteTab")
                )
            ],
            unselectedItemColor:.init(hex: "54648E"),
            font: .font(weight: .medium, size: 14),
            stackViewTopInset: 12,
            stackViewHeight: 57,
            itemWidth: UIScreen.main.bounds.width / 3,
            backgroundColor: .init(hex: "21293E")
        )

        let tabBarController = TabBarController(
            viewControllers: [
                UINavigationController(rootViewController: TVController()),
                UINavigationController(rootViewController: ApplicationsController()),
                UINavigationController(rootViewController: OptionsController())
            ],
            configuration: configuration
        )
        return tabBarController
    }
}
