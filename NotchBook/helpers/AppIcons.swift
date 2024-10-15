//
//  AppIcons.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 09/10/24.
//

import SwiftUI
import AppKit

struct AppIcons {
    
    func getIcon(file path: String) -> NSImage? {
        guard FileManager.default.fileExists(atPath: path)
        else { return nil }
        
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    func getIcon(bundleID: String) -> NSImage? {
        // Get the URL for the application with the given bundle identifier
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        
        // Create an NSWorkspace instance to get the icon
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        
        return icon
    }
    
    func getIcon(application bundleID: String) -> NSImage? {
        // Get the URL for the application with the given bundle identifier
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        
        // Get the path from the URL
        let path = url.path
        
        // Call your existing getIcon function with the application path
        return getIcon(file: path)
    }
    
        /// Easily read Info.plist as a Dictionary from any bundle by accessing .infoDictionary on Bundle
    func bundle(forBundleID: String) -> Bundle? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: forBundleID)
        else { return nil }
        
        return Bundle(url: url)
    }
    
}

func AppIcon(for bundleID: String) -> Image {
    let workspace = NSWorkspace.shared
    
    if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleID) {
        let appIcon = workspace.icon(forFile: appURL.path)
        return Image(nsImage: appIcon)
    }
    
    return Image(nsImage: workspace.icon(for: .applicationBundle))
}

