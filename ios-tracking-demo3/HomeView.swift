//
//  HomeView.swift
//  ios-tracking-demo
//
//  Created by Radhika S on 07/03/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                TrackingManager.shared.startTracking()
            }){
                Text("Start")
            }.buttonStyle(.borderedProminent)
            
            Button(action: {
                TrackingManager.shared.changePace(false)
            }){
                Text("Stop")
            }.buttonStyle(.borderedProminent)
        }
    }
}
