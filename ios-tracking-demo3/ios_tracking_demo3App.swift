//
//  ios_tracking_demo3App.swift
//  ios-tracking-demo3
//
//  Created by Radhika S on 07/03/25.
//

import SwiftUI

@main
struct ios_tracking_demo3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
