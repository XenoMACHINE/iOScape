//
//  AppDelegate.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 15/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        UserManager.shared.initUser()
        WatchManager.shared.connect()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let home = HomeViewController()
        
        window.rootViewController = home
        
        window.makeKeyAndVisible()
        self.window = window
        
        //UILabel.appearance().font = UIFont(name: "Marker Felt Thin", size: 14)
        
        HomeKitManager.shared.load()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        WatchManager.shared.sendAppStatus(.CLOSE)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        WatchManager.shared.sendAppStatus(.OPEN)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

