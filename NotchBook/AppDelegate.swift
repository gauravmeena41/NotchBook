//
//  AppDelegate.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 09/10/24.
//

import AVFoundation
import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var sizing: NotchSizes = .init()
    let vm: NotchBookViewModel = .init()
    let notificationManager: NotificationManager
    
    override init() {
        self.notificationManager = NotificationManager(vm: vm)
        super.init()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupObservers()
        adjustWindowPosition()
        window.orderFrontRegardless()
    }
    
    private func setupWindow() {
        window = NotchWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: sizing.size.opened.width! + 20,
                height: sizing.size.opened.height! + 30
            ),
            styleMask: [.borderless, .nonactivatingPanel, .utilityWindow, .hudWindow],
            backing: .buffered,
            defer: false
        )
        
        window.contentView = NSHostingView(
            rootView: ContentView(
                batteryManager: .init(vm: self.vm, notificationManager: self.notificationManager)
            )
            .environmentObject(vm)
            .environmentObject(MusicManager(vm: vm, notificationManager: notificationManager)!)
            .environmentObject(notificationManager).environmentObject(ScreenLockManager(notificationManager: notificationManager)).environmentObject(VolumeManager(notificationManager: notificationManager)).environmentObject(WiFiManager(notificationManager: notificationManager)))
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustWindowPosition),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil)
    }
    
    func deviceHasNotch() -> Bool {
        if #available(macOS 12.0, *) {
            for screen in NSScreen.screens {
                if screen.safeAreaInsets.top > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    @objc func adjustWindowPosition() {
        guard let windowFrame = window.screen ?? NSScreen.main else { return }
        
        let windowSizes = NotchSizes().size.opened
        
        let windowX = windowFrame.frame.origin.x + (windowFrame.frame.width / 2 - windowSizes.width! / 2)
        // This takes main display x axis origin, add main display frame half width into it and then add notch size half width = we get origin point of our notch window and it's dynamic
        let windowY = windowFrame.frame.height // Doing this for because .frame.origin.y gives y axis origin point 0 and that's screen's bottom origin point
        
        window.setFrameTopLeftPoint(NSPoint(x: windowX, y: windowY))
    }
}
