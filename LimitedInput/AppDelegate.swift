//
//  AppDelegate.swift
//  LimitedInput
//
//  Created by jun on 2022/01/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        let vc = ViewController()
        self.window?.rootViewController = vc
        
        return true
    }

}

