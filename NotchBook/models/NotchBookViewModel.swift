//
//  NotchBookViewModel.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 09/10/24.
//

import Combine
import SwiftUI

class NotchBookViewModel: NSObject, ObservableObject {
    @Published private(set) var notchState: NotchState = .closed
    @Published var notchSize: CGSize = .init(width: NotchSizes().size.closed.width!, height: NotchSizes().size.closed.height!)
    @Published var sizes: NotchSizes = .init()
    @Published var musicPlayerSizes: MusicPlayerElementSizes = .init()
    @Published var coloredSpectrogram: Bool = true
    @Published var headerTitle: String = "NotchBook 🧘🏻"
    @Published var enableHaptics: Bool = true
    @Published var isChargingInfoAllowed: Bool = true
    @Published var waitBeforeExpandingNotch: TimeInterval = 0.5
    
    override init() {
        super.init()
    }
    
    
    
    func openNotch() {
        withAnimation(.spring(.bouncy(duration: 0.4))) {
            self.notchState = .open
            self.notchSize = .init(width:NotchSizes().size.opened.width!, height: NotchSizes().size.opened.height!)
        }
    }
    
    func closeNotch() {
        withAnimation(.spring) {
            self.notchState = .closed
            self.notchSize = .init(width:NotchSizes().size.closed.width!, height: NotchSizes().size.closed.height!)
        }
    }
}
