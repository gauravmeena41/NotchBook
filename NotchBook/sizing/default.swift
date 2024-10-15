//
//  Matters.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 09/10/24.
//


import SwiftUI
import Foundation

struct Area {
    var width: CGFloat?
    var height: CGFloat?
    var inset: CGFloat?
}

struct StatesSizes {
    var opened: Area
    var closed: Area
}

//struct Sizes {
//    var cornerRadius: StatesSizes = StatesSizes(opened: Area(inset: 24), closed: Area(inset: 14))
//    var size: StatesSizes = StatesSizes(
//        opened: Area(width: 580, height: 150),
//        closed: Area(width: 195, height: 32)
//    )
//}

struct NotchSizes {
    let cornerRadius: StatesSizes = StatesSizes(
        opened: Area(inset: 24), closed: Area(inset: 14)
    )
    let size: StatesSizes = StatesSizes(
        opened: Area(width: 550, height: 150, inset: 24),
        closed: Area(width: 194, height: 32, inset: 12)
    )
    
    let sizeWithNotification: StatesSizes = StatesSizes(
        opened: Area(width: 580, height: 150, inset: 24),
        closed: Area(width: 270, height: 60, inset: 16)
    )
}

struct MusicPlayerElementSizes {
    var cornerRadius: StatesSizes = StatesSizes(
        opened: Area(inset: 16), closed: Area(inset: 4)
    )
    var image: StatesSizes = StatesSizes(
        opened: Area(width: 75, height: 75),
        closed: Area(width: 20, height: 20)
    )
}
