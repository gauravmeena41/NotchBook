//
//  PlaybackHelper.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 14/10/24.
//

import AppKit

class PlaybackHelper {
    static func nextTrack(_ playbackManager: MusicPlaybackManager) {
        playbackManager.nextTrack()
    }
    
    static func previousTrack(_ playbackManager: MusicPlaybackManager) {
        playbackManager.prevTrack()
    }
    
    static func togglePlayback(_ playbackManager: MusicPlaybackManager) -> Bool {
        return playbackManager.playPause()
    }
}
