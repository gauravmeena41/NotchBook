//
//  NotificationManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 10/10/24.
//

import Combine
import SwiftUI

struct NotificationItem {
  let message: String
  let iconType: String
  let duration: TimeInterval
  let delay: TimeInterval
}

class NotificationManager: ObservableObject {
  private var isProcessing = false
  private var vm: NotchBookViewModel
  private var notificationSubject = PassthroughSubject<Void, Never>()

  private var cancellables: Set<AnyCancellable> = []

  @Published var notifications: [NotificationItem] = []
  @Published var isNotificationVisible: Bool = false
  @Published var currentNotification: NotificationItem?

  init(vm: NotchBookViewModel) {
    self.vm = vm
    notificationSubject
      .sink { [weak self] in
        self?.startProcessingNotifications()
      }
      .store(in: &cancellables)
  }

  func pushNotification(
    notification: String, iconType: String = "message", duration: TimeInterval = 2.0,
    delay: TimeInterval = 0.0
  ) {
    if notification.isEmpty { return }

    DispatchQueue.main.async { [weak self] in
      self?.notifications.append(
        NotificationItem(
          message: notification, iconType: iconType, duration: duration, delay: delay))
      self?.notificationSubject.send()
    }
  }

  private func startProcessingNotifications() {
    guard !isProcessing else { return }

    isProcessing = true
    processNextNotification()
  }

  private func processNextNotification() {
    if notifications.isEmpty {
      self.isProcessing = false
      return
    }

    processNotification(notifications.removeFirst())
  }

  private func processNotification(_ notification: NotificationItem) {
    if notification.message.isEmpty { return }

    DispatchQueue.main.asyncAfter(deadline: .now() + notification.delay) {
      withAnimation(.bouncy) {
        self.isNotificationVisible = true
        self.currentNotification = notification  // Use the new NotificationItem
      }
    }

    // Set a timer for the current notification to control its display duration
    DispatchQueue.main.asyncAfter(deadline: .now() + notification.duration) { [weak self] in
        withAnimation(.spring) {
        self?.isNotificationVisible = false
      }
      // After the notification is hidden, process the next notification
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self?.processNextNotification()
      }
    }
  }
}
