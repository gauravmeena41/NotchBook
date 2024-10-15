//
//  MusicLiveActivity.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 10/10/24.
//

import SwiftUI

struct MusicLiveActivity: View {
    @EnvironmentObject var vm: NotchBookViewModel
    @EnvironmentObject var musicManager: MusicManager
    
    @State var hoverAnimation: Bool = false
    @Namespace var albumArtNamespace
    
    var body: some View {
        VStack {
            HStack {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .background(
                        Image(nsImage: musicManager.albumArt)
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(width: vm.musicPlayerSizes.image.closed.width, height: vm.musicPlayerSizes.image.closed.height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: vm.musicPlayerSizes.cornerRadius.closed.inset ?? 10))
                    .matchedGeometryEffect(id: "albumArt", in: albumArtNamespace)
                Spacer()
                // Audio spectrum section
                Rectangle()
                    .fill(Color(nsColor: musicManager.avgColor).gradient)
                    .mask {
                        AudioSpectrumView(isPlaying: $musicManager.isPlaying)
                            .frame(width: 16, height: 12)
                    }
                    .frame(
                        width: hoverAnimation ? 100 : vm.sizes.size.closed.height! - 12,
                        height: hoverAnimation ? 100 : vm.sizes.size.closed.height! - 12
                    )
                    .animation(.easeInOut(duration: 0.3), value: hoverAnimation)
            }
            .frame(
                alignment: .center
            )
        }
        .frame(
            width: musicManager.isPlaying
            ? NotchSizes().sizeWithNotification.closed.width! - 25 : NotchSizes().size.closed.width,
            height: 38)
    }
}
