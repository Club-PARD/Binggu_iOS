import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // 전역 변수 선언
    var walkTime1Route1: Int?
    var walkTime2Route1: Int?
    var busTimeRoute1: Int?
    var walkTime1Route2: Int?
    var walkTime2Route2: Int?
    var busTimeRoute2: Int?
    var finalStationRoute1: String?
    var firstStationRoute1: String?
    var busNumRoute1: String?
    var finalStationRoute2: String?
    var firstStationRoute2: String?
    var busNumRoute2: String?
    
    var isRoute1Complete = false
    var isRoute2Complete = false

    var calculator1: RouteCalculator1?
    var calculator2: RouteCalculator2?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Application did finish launching")
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LoadingViewController()
        window?.makeKeyAndVisible()
        
        calculator1 = RouteCalculator1()
        calculator2 = RouteCalculator2()
        
        calculator1?.completionHandler = { [weak self] in
            print("RouteCalculator1 completed")
            self?.isRoute1Complete = true
            DispatchQueue.main.async {
                self?.calculator2?.calculateRoute()
            }
        }
        
        calculator2?.completionHandler = { [weak self] in
            print("RouteCalculator2 completed")
            self?.isRoute2Complete = true
            self?.checkCompletion()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.calculator1?.calculateRoute()
        }
        
        return true
    }

    private func checkCompletion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Checking completion: Route1 = \(self.isRoute1Complete), Route2 = \(self.isRoute2Complete)")
            if self.isRoute1Complete && self.isRoute2Complete {
                self.logAllVariables()
                NotificationCenter.default.post(name: Notification.Name("CalculationsCompleted"), object: nil)
            }
        }
    }

    private func logAllVariables() {
        print("Logging all variables:")
        print("walkTime1Route1: \(walkTime1Route1 ?? -1)")
        print("walkTime2Route1: \(walkTime2Route1 ?? -1)")
        print("busTimeRoute1: \(busTimeRoute1 ?? -1)")
        print("walkTime1Route2: \(walkTime1Route2 ?? -1)")
        print("walkTime2Route2: \(walkTime2Route2 ?? -1)")
        print("busTimeRoute2: \(busTimeRoute2 ?? -1)")
        print("finalStationRoute1: \(finalStationRoute1 ?? "N/A")")
        print("firstStationRoute1: \(firstStationRoute1 ?? "N/A")")
        print("busNumRoute1: \(busNumRoute1 ?? "N/A")")
        print("finalStationRoute2: \(finalStationRoute2 ?? "N/A")")
        print("firstStationRoute2: \(firstStationRoute2 ?? "N/A")")
        print("busNumRoute2: \(busNumRoute2 ?? "N/A")")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
