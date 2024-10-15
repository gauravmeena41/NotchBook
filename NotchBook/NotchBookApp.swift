//
//  NotchBookApp.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 08/10/24.
//

import SwiftUI
import Combine
import AVFoundation
import KeyboardShortcuts
import Cocoa

@main
struct NotchBookApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            NotchBookSettingSView()
                .frame(width: 500, height: 600)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 600)
    }
}
