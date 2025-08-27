import UIKit
import GomaUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create a window programmatically (no storyboard)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // IMPORTANT: For Fast Testing use this navigationController with the necessary component ViewController
        // let preListMatchCardViewController = TallOddsMatchCardViewController()
        // let navigationController = UINavigationController(rootViewController: preListMatchCardViewController)
        
        //
        // Prod lane - Categories list (comment out when testing single components)
        let categoriesVC = CategoriesTableViewController(style: .insetGrouped)
        let navigationController = UINavigationController(rootViewController: categoriesVC)
        //
        //
        
        //
        // Set as root view controller
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
}

