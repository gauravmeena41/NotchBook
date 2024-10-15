//
//  ScreenLockManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 11/10/24.
//

import Cocoa

class ScreenLockManager: ObservableObject {
  private var notificationManager: NotificationManager

  init(notificationManager: NotificationManager) {
    self.notificationManager = notificationManager
    startMonitoring()
  }

  private func startMonitoring() {
    let notificationCenter = DistributedNotificationCenter.default()
    notificationCenter.addObserver(
      self,
      selector: #selector(screenLocked),
      name: NSNotification.Name("com.apple.screenIsLocked"),
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(screenUnlocked),
      name: NSNotification.Name("com.apple.screenIsUnlocked"),
      object: nil
    )
  }

  @objc private func screenLocked() {
    print("Screen Locked")
  }

  @objc private func screenUnlocked() {
    print("Screen Unlocked")
    DispatchQueue.main.async {
      self.notificationManager.pushNotification(
        notification: "Welcome Back" + " " + NSFullUserName().split(separator: " ").first.map(
          String.init
        )!,
        iconType: "hand.wave",
        duration: 3.0,
        delay: 1.0
      )
    }
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }
}
