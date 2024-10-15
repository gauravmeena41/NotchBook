//
//  ContentView.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 08/10/24.
//

import AVFoundation
import Combine
import KeyboardShortcuts
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: NotchBookViewModel
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var volumneManager: VolumeManager
    @StateObject var batteryManager: BatteryStatusManager
    
    @State private var haptics: Bool = false
    @State private var isHovering: Bool = false
    @State private var hoveringTimer: Timer?
    
    var body: some View {
        let notchSizes = NotchSizes().size
        let notchSizesWithNotification = NotchSizes().sizeWithNotification
        let isClosed = vm.notchState == .closed
        let isPlaying = musicManager.isPlaying
        let isNotificationVisible = notificationManager.isNotificationVisible
        
        ZStack {
            NotchBookLayout()
                .padding([.horizontal], isClosed ? 0 : 30)
                .padding([.bottom], isClosed ? 0 : 15)
                .frame(
                    width: isClosed ? notchSizes.closed.width : notchSizes.opened.width,
                    height: isClosed ? notchSizes.closed.height : notchSizes.opened.height!
                )
                .frame(
                    maxWidth: isClosed
                    ? ((isPlaying || isNotificationVisible || volumneManager.isVolumeChanged)
                       ? notchSizesWithNotification.closed.width!  + (self.isHovering ? 15 : 0) : notchSizes.closed.width! + (self.isHovering ? 15 : 0))
                    : notchSizes.opened.width,
                    maxHeight: isClosed
                    ? (isNotificationVisible || volumneManager.isVolumeChanged)
                    ? notchSizesWithNotification.closed.height!
                    + ((!isNotificationVisible && volumneManager.isVolumeChanged) ? 5 : 0)
                    : notchSizes.closed.height! + (self.isHovering ? 10 : 0) : notchSizes.opened.height!
                )
                .background(.black)
                .mask {
                    NotchShape(
                        cornerRadius: isClosed
                        ? vm.sizes.cornerRadius.closed.inset : vm.sizes.cornerRadius.opened.inset)
                }
                .sensoryFeedback(.alignment, trigger: haptics)
                .onHover { hovering in
                    if hovering {
                        withAnimation(.spring(.bouncy(duration: 0.4))) {
                            self.isHovering = true
                            haptics.toggle()
                        }
                        
                        self.hoveringTimer = Timer.scheduledTimer(withTimeInterval: vm.waitBeforeExpandingNotch, repeats: false) { _ in
                            vm.openNotch()
                            haptics.toggle()
                        }
                    } else {
                        self.hoveringTimer?.invalidate()
                        
                        withAnimation(.spring(.bouncy(duration: 0.4))) {
                            self.isHovering = false
                            haptics.toggle()
                        }
                        vm.closeNotch()
                    }
                }
        }
        .frame(
            maxWidth: notchSizes.opened.width!, maxHeight: notchSizes.opened.height!, alignment: .top
        )
        .shadow(color: .black.opacity(0.6), radius: 10)
        .environmentObject(vm)
        .environmentObject(batteryManager)
        .environmentObject(musicManager)
        .environmentObject(notificationManager)
    }
}
