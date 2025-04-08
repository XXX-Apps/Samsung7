import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        //        if !LocalDataBase.shared.isOnboardingShown {
        //            let onboardingViewController = OnboardingViewController()
        //            let navigationController = UINavigationController(rootViewController: onboardingViewController)
        //            window.rootViewController = navigationController
        //
        //        } else {
        window.rootViewController = TabBarConfigurator.main()
        //        }
        
        window.makeKeyAndVisible()
    }
}

