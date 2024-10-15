//
//  MusicManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 09/10/24.
//

import AppKit
import Combine
import SwiftUI

var defaultAlbumArt: NSImage = .init(
    systemSymbolName: "heart.fill",
    accessibilityDescription: "Default album art"
)!

class MusicManager: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var vm: NotchBookViewModel
    private var notificationManager: NotificationManager
    
    @Published var songTitle: String = ""
    @Published var artistName: String = ""
    @Published var album: String = "album"
    @Published var albumArt: NSImage = defaultAlbumArt
    @Published var isPlaying: Bool = false
    @Published var playbackManager = MusicPlaybackManager()
    @Published var lastUpdated: Date = .init()
    @Published var avgColor: NSColor = .white
    @Published var audioPlayerBundleIndentifier: String = "com.apple.Music"
    
    var nowPlaying: NowPlaying
    private let mediaRemoteBundle: CFBundle
    private let MRMediaRemoteGetNowPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let MRMediaRemoteRegisterForNowPlayingNotifications: @convention(c) (DispatchQueue) -> Void
    private var playerStateChangeTimer: Timer?
    private let defaultAudioPlayerBundleIndentifier: String = "com.apple.Music"
    
    init?(vm: NotchBookViewModel, notificationManager: NotificationManager) {
        self.vm = vm
        self.notificationManager = notificationManager
        
        nowPlaying = NowPlaying()
        
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
            print("Could not load MediaRemote.framework")
            return nil
        }
        
        self.mediaRemoteBundle = bundle
        
        guard let MRMediaPlayingGetNowPlayingPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
              let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) else {
            print("Failed to get function pointers for MediaRemote.framework")
            return nil
        }
        
        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaPlayingGetNowPlayingPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
        self.MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: (@convention(c) (DispatchQueue) -> Void).self)
        
        setupNowPlayingObserver()
        fetchNowPlayingInfo()
        
        if nowPlaying.playing {
            self.fetchNowPlayingInfo()
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private func setupNowPlayingObserver() {
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.fetchNowPlayingInfo(bundle: self.nowPlaying.appBundleIdentifier)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("kMRMediaRemoteNowPlayingApplicationDidChangeNotification"))
            .sink { [weak self] _ in
                self?.updateApp()
            }
            .store(in: &cancellables)
        
        let bundles = ["com.spotify.client", "com.apple.Music"]
        for bundle in bundles {
            DistributedNotificationCenter.default().addObserver(
                forName: NSNotification.Name("\(bundle).PlaybackStateChanged"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.fetchNowPlayingInfo(bundle: bundle)
            }
        }
    }
    
    @objc func updateApp() {
        self.audioPlayerBundleIndentifier = nowPlaying.appBundleIdentifier ?? defaultAudioPlayerBundleIndentifier
    }
    
    @objc func fetchNowPlayingInfo(bypass: Bool = false, bundle: String? = nil) {
        audioPlayerBundleIndentifier = (bundle == "com.apple.WebKit.GPU") ? "com.apple.Safari" : (bundle ?? audioPlayerBundleIndentifier)
        
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] information in
            guard let self = self else { return }
            
            let newSongTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
            let newArtistName = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
            let newAlbumName = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? ""
            let newArtworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data ?? AppIcons().getIcon(bundleID: self.audioPlayerBundleIndentifier)?.tiffRepresentation
            
            let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Int
            
            let musicPlayingState = playbackRate == 1
            
            playerStateChangeTimer?.invalidate()
            
            playerStateChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                guard let self = self, let artworkImage = NSImage(data: newArtworkData!) else {
                    return
                }
                
                print("playerStateChangeTimer")
                
                self.updatePlaybackState(musicPlayingState: musicPlayingState, albumArtwork: artworkImage, songTitle: newSongTitle, albumTitle: newAlbumName, artistName: newArtistName)
            }
        }
    }
    
    private func updatePlaybackState(musicPlayingState: Bool, albumArtwork: NSImage, songTitle: String, albumTitle: String, artistName: String) {
        guard (musicPlayingState != self.isPlaying || songTitle != self.songTitle) else { return }

        withAnimation(.default) {
            self.isPlaying = musicPlayingState
            self.lastUpdated = Date()
            self.songTitle = songTitle
            self.album = albumTitle
            self.artistName = artistName
            
            fetchNowPlayingInfo()
            updateAlbumArt(newAlbumArt: albumArtwork)
        }
        
        if musicPlayingState {
            self.notificationManager.pushNotification(notification: self.songTitle, iconType: "music.note")
        }
    }
    
    func togglePlayPause() {
        _ = PlaybackHelper.togglePlayback(playbackManager)
    }
    func updateAlbumArt(newAlbumArt: NSImage) {
        if self.albumArt.tiffRepresentation != newAlbumArt.tiffRepresentation {
            print("called updateAlbumArt")
            self.albumArt = newAlbumArt
            
            let albumArtworkRGB = ImageHelper.calculateAverageColor(from: self.albumArt)!
            self.avgColor = albumArtworkRGB
        }
    }
    
    func nextTrack() {
        PlaybackHelper.nextTrack(playbackManager)
        fetchNowPlayingInfo(bypass: true)
    }
    
    func previousTrack() {
        PlaybackHelper.previousTrack(playbackManager)
        fetchNowPlayingInfo(bypass: true)
    }
    
    private func animate(_ changes: () -> Void, animationType: Animation = .default) {
        withAnimation(animationType, changes)
    }
}
