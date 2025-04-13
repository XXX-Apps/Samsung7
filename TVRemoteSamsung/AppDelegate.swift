import UIKit
import TVRemoteControl
import PremiumManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let connectionManager = SamsungTVConnectionService.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        FirebaseApp.configure()
        PremiumManager.shared.configure(with: .init(apiKey: Config.apphudKey, debugMode: true))
        PremiumManager.shared.fetchProducts()
        
        if let device = LocalDataBase.shared.restoreConnectedDevice() {
            connectionManager.connect(to: device, appName: Config.appName, commander: nil)
        }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }

        application.registerForRemoteNotifications()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PremiumManager.shared.submitPushNotificationsToken(deviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {}
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        PremiumManager.shared.handlePushNotification(notification: response.notification)
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        PremiumManager.shared.handlePushNotification(notification: notification)
        completionHandler([])
    }
}

extension UIView {
    public func addCircleInnerShadow(
        shadowColor: UIColor = .black,
        opacity: Float = 0.15,
        shadowOffset: CGSize = CGSize(width: 0, height: 8),
        insets: CGPoint = .init(x: 1, y: 1)
    ) {
        let innerShadow = CALayer()
        innerShadow.name = "innerShadow"
        innerShadow.frame = bounds
        
        let radius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: insets.x, dy: insets.y), cornerRadius: radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: radius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        innerShadow.shadowColor = shadowColor.cgColor
        innerShadow.shadowOffset = shadowOffset
        innerShadow.shadowOpacity = opacity
        innerShadow.shadowRadius = 2
        innerShadow.cornerRadius = self.layer.cornerRadius
        layer.addSublayer(innerShadow)
    }
}

