//
//  AppDelegate.swift
//  SimpleInput
//
//  Created by galaxy on 2022/2/8.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        let vc = ViewController(style: .plain)
        let navi = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = navi
        return true
    }
}
