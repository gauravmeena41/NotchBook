//
//  VolumeManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 12/10/24.
//

import AudioToolbox
import CoreAudio
import SwiftUI

class VolumeManager: ObservableObject {
    private var notificationManager: NotificationManager
    @Published var currentVolume: Float = 0.0
    @Published var isVolumeChanged: Bool = false
    private var defaultOutputDeviceID = AudioDeviceID(0)
    
    private var volumeChangeWorkItem: DispatchWorkItem?
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
        setupAudioDevice()
        currentVolume = getSystemVolume()
        startMonitoring()  // Start monitoring volume changes
    }
    
    func setupAudioDevice() {
        var propertySize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &defaultOutputDeviceID)
        
        if status != noErr {
            print("Error getting default output device ID")
        }
    }
    
    func getSystemVolume() -> Float {
        var volume = Float32(0)
        var propertySize = UInt32(MemoryLayout.size(ofValue: volume))
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain)
        
        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &address,
            0,
            nil,
            &propertySize,
            &volume)
        
        if status != noErr {
            print("Error getting volume")
            return 0.0
        }
        
        if self.currentVolume != volume {
            volumeChangeWorkItem?.cancel()
            
            withAnimation(.spring) {
                self.isVolumeChanged = true
            }
            
            let workItem = DispatchWorkItem {
                withAnimation(.spring) {
                    self.isVolumeChanged = false
                }
            }
            
            volumeChangeWorkItem = workItem
            
            withAnimation(.spring) {
                self.isVolumeChanged = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
        }
        
        return volume
    }
    
    func startMonitoring() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain)
        
        let status = AudioObjectAddPropertyListener(
            defaultOutputDeviceID, &address, volumeChangeListener,
            Unmanaged.passUnretained(self).toOpaque())
        
        if status != noErr {
            print("Error adding volume observer")
        }
    }
}

private func volumeChangeListener(
    objectID: AudioObjectID,
    numberOfAddresses: UInt32,
    addresses: UnsafePointer<AudioObjectPropertyAddress>,
    clientData: UnsafeMutableRawPointer?
) -> OSStatus {
    let audioManager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
    DispatchQueue.main.async {
        withAnimation(.spring) {
            audioManager.currentVolume = audioManager.getSystemVolume()
        }
    }
    
    return noErr
}
