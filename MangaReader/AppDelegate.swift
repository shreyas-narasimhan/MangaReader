import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        print("🚀 App Launched") // ADD THIS
        
        window = UIWindow(frame: UIScreen.main.bounds)

        let rootVC = LibraryViewController()
        let nav = UINavigationController(rootViewController: rootVC)

        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        return true
    }
    
}
