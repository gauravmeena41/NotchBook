//
//  NotificationView.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 12/10/24.
//

import SwiftUI

struct NotificationView: View {
    
    let notification: String?
    let notificationIconType: String?
    
    var body: some View {
        HStack {
            Spacer()
            HStack(alignment: .center, spacing: 5) {
                Image(nsImage: NSImage.init(systemSymbolName: notificationIconType!, accessibilityDescription: "notification icon")!)
                    .foregroundColor(.gray)
                Text(notification!)
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .animation(.bouncy)
            }
            .foregroundStyle(.gray)
            .padding(.bottom, 10)
            Spacer()
        }
    }
}
