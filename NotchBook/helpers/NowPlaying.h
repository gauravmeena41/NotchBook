/**
 * @file NowPlaying.h
 *
 * @copyright 2018-2019 Bill Zissimopoulos
 */
/*
 * This file is part of EnergyBar.
 *
 * You can redistribute it and/or modify it under the terms of the GNU
 * General Public License version 3 as published by the Free Software
 * Foundation.
 */

#import <Cocoa/Cocoa.h>

@interface NowPlaying : NSObject

// Singleton instance
+ (instancetype)sharedInstance;

// Properties to hold application and media information
@property (nonatomic, copy) NSString *appBundleIdentifier; // Bundle Identifier of the app currently playing media
@property (nonatomic, copy) NSString *appName;             // Name of the app currently playing media
@property (nonatomic, strong) NSImage *appIcon;             // Icon of the app currently playing media
@property (nonatomic, copy) NSString *album;                // Album of the currently playing media
@property (nonatomic, copy) NSString *artist;               // Artist of the currently playing media
@property (nonatomic, copy) NSString *title;                // Title of the currently playing media
@property (nonatomic, assign) BOOL playing;                 // Playing state of the media

@end

// Notification names for observing state changes
extern NSString *const NowPlayingInfoNotification; // Notification when NowPlaying info changes
extern NSString *const NowPlayingStateNotification; // Notification when NowPlaying state changes
