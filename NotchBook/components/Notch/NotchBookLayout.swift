//
//  NotchBookLayout.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 10/10/24.
//

import Combine
import SwiftUI

struct NotchBookLayout: View {

  @EnvironmentObject var vm: NotchBookViewModel
  @EnvironmentObject var musicManager: MusicManager
  @EnvironmentObject var notificationManager: NotificationManager
  @EnvironmentObject var batteryManager: BatteryStatusManager
  @EnvironmentObject var volumeManager: VolumeManager

  @Namespace var albumArtNamespace

  @State var hoverAnimation: Bool = false

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        if vm.notchState == .closed {
          VStack {
            if musicManager.isPlaying {
              MusicLiveActivity()
            } else {
              Spacer()
            }
            if notificationManager.isNotificationVisible,
              let notification = notificationManager.currentNotification
            {
              NotificationView(
                notification: notification.message.count > 30
                  ? String(notification.message.prefix(30)) + "..."
                  : notification.message,
                notificationIconType: notification.iconType
              )
            } else if !notificationManager.isNotificationVisible && volumeManager.isVolumeChanged {
              VolumeView(currentVolume: Int32(volumeManager.currentVolume * 100))
            }
          }
          .frame(
            width: NotchSizes().sizeWithNotification.closed.width!,
            height: NotchSizes().sizeWithNotification.closed.height!)

        } else if vm.notchState == .open {
          NotchBookHomeView(albumArtNamespace: albumArtNamespace)
        }
      }
    }
  }

}
