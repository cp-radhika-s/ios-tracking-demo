//
//  AppDelegate.swift
//  ios-tracking-demo
//
//  Created by Radhika S on 07/03/25.
//

import UIKit
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func applicationWillTerminate(_ application: UIApplication) {
        //print("applicationWillTerminate")
        TrackingManager.shared.applicationWillTerminate()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        self.requestNotificationPermission()
      
        TrackingManager.shared.log("App launched \(String(describing: launchOptions))")

        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            TrackingManager.shared.log("App relaunched due to significant location change")
            TrackingManager.shared.changePace(true)
        }
        
        return true
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }
}

