//
//  NotchBookHome.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 10/10/24.
//

import SwiftUI

struct NotchBookHomeView: View {
    
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var vm: NotchBookViewModel
    @EnvironmentObject var batteryManager: BatteryStatusManager
    
    let albumArtNamespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerView

            HStack (alignment: .bottom, spacing: 20) {
                albumArtView
                
                VStack(alignment: .leading, spacing: 10) {
                    songDetailsView
                    
                    controlButtons
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(vm.notchState == .closed ? 0 : 1)
                .blur(radius: vm.notchState == .closed ? 20 : 0)
            }
        }
    }
    
//     MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text(vm.headerTitle)
                .font(.subheadline)
                .fontWeight(.bold)
            
            Spacer()
            if vm.notchState == .open {
                SettingsLink {
                    Capsule()
                        .fill(.black)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                                .padding()
                                .imageScale(.medium)
                        }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack {
                Image(systemName: batteryManager.powerSource == "AC Power" ? "battery.100.bolt" : "battery.100")
                    .foregroundColor(
                        batteryManager.powerSource == "AC Power" ? .lightGreen : .white
                    )
                Text("\(Int32(batteryManager.batteryPercentage))%")
                    .font(.subheadline)
            }
        }
    }
    
    private var albumArtView: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .background(
                    Image(nsImage: musicManager.albumArt)
                        .resizable()
                        .scaledToFill()
                )
                .frame(width: vm.musicPlayerSizes.image.opened.width, height: vm.musicPlayerSizes.image.opened.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: vm.musicPlayerSizes.cornerRadius.opened.inset ?? 10))
                .matchedGeometryEffect(id: "albumArt", in: albumArtNamespace)
            
            if vm.notchState == .open {
                AppIcon(for: musicManager.audioPlayerBundleIndentifier)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
                    .offset(x: 10, y: 10)
                    .transition(.scale.combined(with: .opacity).animation(.bouncy.delay(0.3)))
            }
        }
    }
    
    private var songDetailsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .leading) {
                Text(musicManager.songTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 150, alignment: .leading) // Removed unnecessary GeometryReader
                    .clipped()
            }
            .frame(height: 10)
            
            ZStack(alignment: .leading) {
                Text(musicManager.artistName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 150, alignment: .leading) // Removed unnecessary GeometryReader
                    .clipped()
            }
            .frame(height: 10)
        }
        .padding(.leading, 5)
    }
    
    private var controlButtons: some View {
        HStack(spacing: 5) {
            HoverButton(icon: "backward.fill") {
                musicManager.previousTrack()
            }
            
            HoverButton(icon: playPauseIcon) {
                musicManager.togglePlayPause()
            }
            
            HoverButton(icon: "forward.fill") {
                musicManager.nextTrack()
            }
        }
    }
    
    // MARK: - Helpers
    
    private var playPauseIcon: String {
        return self.musicManager.isPlaying ? "pause.fill" : "play.fill"
    }
}
