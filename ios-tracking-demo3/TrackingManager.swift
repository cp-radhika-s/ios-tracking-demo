//
//  TrackingManager.swift
//  ios-tracking-demo
//
//  Created by Radhika S on 07/03/25.
//

import CoreLocation
import CoreMotion
import UIKit

enum TrackingState {
    case moving
    case stationary
}

class TrackingManager: NSObject, CLLocationManagerDelegate {
    static let shared = TrackingManager()
    
    var onLocationUpdate: ((CLLocation) -> Void)?
    var currentState: TrackingState = .stationary
    
    private let locationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    private var stopTimeoutTimer: Timer?
    private let stopTimeout: TimeInterval = 300 // 5 minutes
    
    var addStationaryRegion: Bool = false
    var lastLocation: CLLocation?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 50
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
    }

    // Delegate: Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        handleLocationUpdate(currentLocation)
        if addStationaryRegion {
            setupStationaryGeofence()
            addStationaryRegion = false
        }
    }

    // Delegate: Handle geofence exit
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "stationaryRegion" {
            locationManager.stopMonitoring(for: region)
            log("Exit the stationary region")
            changePace(true) // Resume tracking
        }
    }
 
    
    func startTracking() {
        log("Start tracking...")
        locationManager.requestAlwaysAuthorization()
        startMonitoringMotion()
        locationManager.startMonitoringSignificantLocationChanges()
        changePace(true)
        //locationManager.startUpdatingLocation()
        //changePace(false)
        //addStationaryRegion = true
    }
    
    func changePace(_ isMoving: Bool) {
        if isMoving {
            enterMovingState()
        } else {
            enterStationaryState()
        }
    }
    
    private func enterMovingState() {
        log("enter Moving State...")
        stopTimeoutTimer?.invalidate()
        currentState = .moving
        locationManager.startUpdatingLocation()
    }
    
    private func enterStationaryState() {
        currentState = .stationary
        log("enter Stationary State...")
        setupStationaryGeofence()
        locationManager.stopUpdatingLocation()
    }
    
    func applicationWillTerminate(){
        log("Application will terminate")
        //setupStationaryGeofence()
    }
    
    func setupStationaryGeofence() {
        if let location = lastLocation {
            let region = CLCircularRegion(center: location.coordinate, radius: 100, identifier: "stationaryRegion")
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
            log("startMonitoring region")
        }
    }
    
    func handleStationaryDetected() {
        guard currentState == .moving else { return }
        stopTimeoutTimer = Timer.scheduledTimer(withTimeInterval: stopTimeout, repeats: false) { [weak self] _ in
            self?.log("Motion detected...")
            self?.enterStationaryState()
        }
    }
    
    func handleLocationUpdate(_ location: CLLocation) {
        if lastLocation != nil {
            log("Receive location distnce: \(location.distance(from: lastLocation!))...")
        }
        lastLocation = location
        
        onLocationUpdate?(location)
    }
    
    func startMonitoringMotion() {
    
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] activity in
                guard let self = self, let activity = activity else { return }
                
                if activity.stationary {
                    handleStationaryDetected()
                } else if activity.walking || activity.running || activity.automotive {
                    guard self.currentState == .stationary else { return }
                    log("Motion detected - moving")
                    changePace(true)
                }
            }
        }
    }
    
    func log(_ message: String){
        sendInstantNotification(message)
        print("Log \(message)")
    }
    
    func sendInstantNotification(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Tracking.."
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
