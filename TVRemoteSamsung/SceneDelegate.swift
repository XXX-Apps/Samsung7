import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var coordinator: OnboardingCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if !LocalDataBase.shared.isOnboardingShown {
            coordinator = OnboardingCoordinator(window: window)
            coordinator?.start()
        } else {
            window.rootViewController = TabBarConfigurator.main()
        }
        
        window.makeKeyAndVisible()
    }
}

