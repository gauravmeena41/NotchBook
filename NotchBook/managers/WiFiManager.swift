//
//  WifiManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 13/10/24.
//

import Combine
import Foundation
import Network

class WiFiManager: ObservableObject {
  private let notificationManager: NotificationManager
  private var monitor: NWPathMonitor?
  private var wifiPathStatus: NWPath.Status?

  init(notificationManager: NotificationManager) {
    self.notificationManager = notificationManager
    startMonitoring()
  }

  private func startMonitoring() {
    monitor = NWPathMonitor()
    monitor?.pathUpdateHandler = { path in
      DispatchQueue.main.async {
        if path.status == .satisfied && path.usesInterfaceType(.wifi) {
          if path.status != self.wifiPathStatus {
            self.notificationManager.pushNotification(
              notification: "Wi-Fi Connected", iconType: "wifi", duration: 5.0)
          }
          self.wifiPathStatus = path.status
        } else {
          if path.status != self.wifiPathStatus {
            self.notificationManager.pushNotification(
              notification: "Wi-Fi Disconnected", iconType: "wifi.slash", duration: 5.0)
          }
          self.wifiPathStatus = path.status
        }
      }
    }
    let queue = DispatchQueue(label: "WiFiMonitor")
    monitor?.start(queue: queue)
  }

  deinit {
    monitor?.cancel()
  }
}
