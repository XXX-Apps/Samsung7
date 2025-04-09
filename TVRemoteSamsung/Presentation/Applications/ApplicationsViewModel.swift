//import UIKit
//import TVRemoteControl
//
//final class ApplicationsViewModel {
//    
//    let tvAppManager = TVAppManager()
//    
//    var apps: [TVApp] = TVApp.allApps()
//    
//    func openApp(app: TVApp) {
//        if let ipAddress = TVConnectionManager.shared.connectedDevice?.ipAddress {
//            Task {
//                try await tvAppManager.launch(tvApp: app, tvIPAddress: ipAddress)
//            }
//        }
//    }
//}
//
//extension TVApp {
//    
//    var image: UIImage? {
//        switch name {
//        case "ESPN":
//            return UIImage(named: "espn")
//        case "Hulu":
//            return UIImage(named: "hulu")
//        case "Max":
//            return UIImage(named: "max")
//        case "Netflix":
//            return UIImage(named: "netflix")
//        case "Paramount +":
//            return UIImage(named: "paramount")
//        case "Pluto TV":
//            return UIImage(named: "pluto")
//        case "Prime Video":
//            return UIImage(named: "prime")
//        case "Spotify":
//            return UIImage(named: "spotify")
//        case "YouTube":
//            return UIImage(named: "youtube")
//        default:
//            return nil
//        }
//    }
//}
//
