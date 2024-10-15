//
//  BatteryStatusManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 10/10/24.
//

import Cocoa
import SwiftUI
import IOKit.ps
import Combine

class BatteryStatusManager: ObservableObject {
    private var vm: NotchBookViewModel
    private var notificationManager: NotificationManager
    
    @Published var batteryPercentage: Float = 0.0
    @Published var isPluggedIn: Bool = false
    @Published var showChargingInfo: Bool = false
    @Published var powerSource: String = ""
    @Published var powerSourceDisplay: Bool = true
    
    private var powerSourceChangeCallback: IOPowerSourceCallbackType?
    private var runLoopSource: Unmanaged<CFRunLoopSource>?
    private var powerSourceDisplayTimer: AnyCancellable?
    
    init(vm: NotchBookViewModel, notificationManager: NotificationManager) {
        self.vm = vm
        self.notificationManager = notificationManager
        // Call updateBatteryStatus on the main actor
        Task { @MainActor in
            self.updateBatteryStatus() // Ensure it runs on the main thread
        }
        startMonitoring() // This can remain as is since it does not need @MainActor
    }
    
    @MainActor
    @objc private func updateBatteryStatus() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else { return }
        
        for source in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: AnyObject],
               let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = info[kIOPSMaxCapacityKey] as? Int,
               let isCharging = info["Is Charging"] as? Bool,
               let powerSource = info["Power Source State"] as? String {
                
                if vm.isChargingInfoAllowed {
                    batteryPercentage = Float(currentCapacity * 100) / Float(maxCapacity)
                    
                    // Update charging info state
                    if isCharging && !self.isPluggedIn {
                        showChargingInfo = true
                        isPluggedIn = true
                    }
                    
                    isPluggedIn = isCharging
                    handlePowerSourceDisplayTimer(powerSource: powerSource)
                }
            }
        }
    }
    
    private func startMonitoring() {
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        powerSourceChangeCallback = { context in
            if let context = context {
                let mySelf = Unmanaged<BatteryStatusManager>.fromOpaque(context).takeUnretainedValue()
                // Ensure updateBatteryStatus is called on the main actor
                Task { @MainActor in
                    mySelf.updateBatteryStatus() // Ensure this runs on the main thread
                }
            }
        }
        
        if let runLoopSource = IOPSNotificationCreateRunLoopSource(powerSourceChangeCallback!, context)?.takeUnretainedValue() {
            self.runLoopSource = Unmanaged<CFRunLoopSource>.passRetained(runLoopSource)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)
        }
    }
    
    deinit {
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource.takeUnretainedValue(), .defaultMode)
            runLoopSource.release()
        }
    }
    
    @objc private func handlePowerSourceDisplayTimer(powerSource: String) {
        guard !powerSource.isEmpty, powerSource != self.powerSource else { return }
        
        let notificationMessage = "\(powerSource) / \(Int32(batteryPercentage))%"
        notificationManager.pushNotification(notification: notificationMessage, iconType: powerSource == "AC Power" ? "battery.100.bolt" : "battery.100")
        
        withAnimation(.bouncy) {
            self.powerSource = powerSource
            self.powerSourceDisplay = true
        }
        
        powerSourceDisplayTimer?.cancel() // Cancel previous timer if any
        
        powerSourceDisplayTimer = Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation(.bouncy) {
                    self?.powerSourceDisplay = false
                }
            }
    }
}
