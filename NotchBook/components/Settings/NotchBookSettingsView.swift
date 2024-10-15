//
//  NotchBookSettingSView.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 12/10/24.
//

import SwiftUI


struct NotchBookSettingSView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var selectedTab: SettingsEnum = .about
    
    
    
    var body: some View {
        TabView (selection: $selectedTab,
                 content: {
            GeneralSettings()
                .tabItem{Label("General", systemImage: "gear")}
                .tag(SettingsEnum.general)
            MediaPlayback()
                .tabItem{Label("Media Playback", systemImage: "play.laptopcomputer")}
                .tag(SettingsEnum.mediaPlayback)
            About()
                .tabItem{Label("About", systemImage: "info.circle")}
                .tag(SettingsEnum.about)
        })
        .formStyle(.grouped)
        .tint(.accentColor)
        .onChange(of:scenePhase) {
            _, phase in
            
            if phase == .active {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) {
            _ in
            NSApp.setActivationPolicy(.accessory)
            NSApp.deactivate()
        }
    }
    
    @ViewBuilder
    func GeneralSettings() -> some View {
        VStack {
            Text("General Settings")
        }
    }
    
    @ViewBuilder
    func MediaPlayback() -> some View {
        Text("Media Playback Settings")
    }
    
    @ViewBuilder
    func About() -> some View {
        VStack {
            Button ("Quit NotchBook", role: .destructive) {
                exit(0)
            }
        }
    }
    
}


#Preview {
    NotchBookSettingSView()
}
