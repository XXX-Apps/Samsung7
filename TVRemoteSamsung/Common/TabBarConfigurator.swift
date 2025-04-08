import CustomTabBar
import UIKit
import Utilities

final class TabBarConfigurator {
    static func main() -> TabBarController {
        let configuration = TabBarConfiguration(
            cornerRadius: 0,
            stackViewSpacing: 0,
            tabBarHeight: UIScreen.isLittleDevice ? 83 : 105,
            tabBarItems: [
                .init(
                    title: "Controller".localized,
                    image: UIImage(named: "controllerTab")
                ),
                .init(
                    title: "Applications".localized,
                    image: UIImage(named: "applicationsTab")
                ),
                .init(
                    title: "Options".localized,
                    image: UIImage(named: "optionsTab")
                )
            ],
            unselectedItemColor:.init(hex: "7575AF"),
            font: .font(weight: .regular, size: 14),
            stackViewTopInset: 12,
            stackViewHeight: 57,
            itemWidth: UIScreen.main.bounds.width / 3,
            backgroundColor: .init(hex: "1B1B47")
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
