

import SwiftUI

@main
struct BlockBoost: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    init(){
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//    }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    static var portrito = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: portrito))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if portrito == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.portrito
    }
}
