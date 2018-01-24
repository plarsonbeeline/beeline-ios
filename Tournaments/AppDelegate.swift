//
//  AppDelegate.swift
//  Tournaments
//
//  Created by Phil Larson on 1/23/18.
//  Copyright © 2017 Phil Larson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Initialize
    
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    
    func loadWindow() {
        let window = UIWindow()
        window.rootViewController = self.rootNavigationController
        window.makeKeyAndVisible()
        self.window = window
    }
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.loadWindow()
        return true
    }
    
    // MARK: - Accessing
    
    var window: UIWindow?
    
    lazy var rootNavigationController: UINavigationController = {
        return UINavigationController(rootViewController: self.rootViewController)
    }()
    
    lazy var rootViewController: RootViewController = {
        return RootViewController()
    }()

}

