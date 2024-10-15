#import "NowPlaying.h"

typedef void (^MRMediaRemoteGetNowPlayingInfoBlock)(NSDictionary *info);
typedef void (^MRMediaRemoteGetNowPlayingClientBlock)(id clientObj);
typedef void (^MRMediaRemoteGetNowPlayingApplicationIsPlayingBlock)(BOOL playing);

void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
void MRMediaRemoteGetNowPlayingClient(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingClientBlock block);
void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoBlock block);
void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationIsPlayingBlock block);

NSString *MRNowPlayingClientGetBundleIdentifier(id clientObj);
NSString *MRNowPlayingClientGetParentAppBundleIdentifier(id clientObj);

extern NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
extern NSString *kMRMediaRemoteNowPlayingApplicationClientStateDidChange;
extern NSString *kMRNowPlayingPlaybackQueueChangedNotification;
extern NSString *kMRPlaybackQueueContentItemsChangedNotification;
extern NSString *kMRMediaRemoteNowPlayingApplicationDidChangeNotification;

extern NSString *kMRMediaRemoteNowPlayingInfoAlbum;
extern NSString *kMRMediaRemoteNowPlayingInfoArtist;
extern NSString *kMRMediaRemoteNowPlayingInfoTitle;

@implementation NowPlaying

NSString *const NowPlayingInfoNotification = @"NowPlayingInfo";
NSString *const NowPlayingStateNotification = @"NowPlayingState";

+ (void)load {
    MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());
}

+ (instancetype)sharedInstance {
    static NowPlaying *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerForNotifications];
        [self updateApp];
        [self updateInfo];
        [self updateState];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appDidChange:) name:kMRMediaRemoteNowPlayingApplicationDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(infoDidChange:) name:kMRMediaRemoteNowPlayingApplicationClientStateDidChange object:nil];
    [center addObserver:self selector:@selector(infoDidChange:) name:kMRNowPlayingPlaybackQueueChangedNotification object:nil];
    [center addObserver:self selector:@selector(infoDidChange:) name:kMRPlaybackQueueContentItemsChangedNotification object:nil];
    [center addObserver:self selector:@selector(playingDidChange:) name:kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
}

- (void)updateApp {
    MRMediaRemoteGetNowPlayingClient(dispatch_get_main_queue(), ^(id clientObj) {
        NSString *appBundleIdentifier = [self bundleIdentifierForClient:clientObj];
        NSString *appName = nil;
        NSImage *appIcon = nil;

        if (appBundleIdentifier) {
            NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:appBundleIdentifier];
            if (path) {
                appName = [[NSFileManager defaultManager] displayNameAtPath:path];
                appIcon = [[NSWorkspace sharedWorkspace] iconForFile:path];
            }
        }

        [self updateAppPropertiesWithBundleIdentifier:appBundleIdentifier name:appName icon:appIcon];
    });
}

- (NSString *)bundleIdentifierForClient:(id)clientObj {
    if (!clientObj) return nil;
    NSString *bundleIdentifier = MRNowPlayingClientGetBundleIdentifier(clientObj);
    return bundleIdentifier ?: MRNowPlayingClientGetParentAppBundleIdentifier(clientObj);
}

- (void)updateAppPropertiesWithBundleIdentifier:(NSString *)bundleIdentifier name:(NSString *)name icon:(NSImage *)icon {
    if (![self.appBundleIdentifier isEqualToString:bundleIdentifier] ||
        ![self.appName isEqualToString:name] ||
        self.appIcon != icon) {
        
        self.appBundleIdentifier = bundleIdentifier;
        self.appName = name;
        self.appIcon = icon;

        [[NSNotificationCenter defaultCenter] postNotificationName:NowPlayingInfoNotification object:self];
    }
}

- (void)updateInfo {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(NSDictionary *info) {
        NSString *album = info[kMRMediaRemoteNowPlayingInfoAlbum];
        NSString *artist = info[kMRMediaRemoteNowPlayingInfoArtist];
        NSString *title = info[kMRMediaRemoteNowPlayingInfoTitle];

        [self updateInfoPropertiesWithAlbum:album artist:artist title:title];
    });
}

- (void)updateInfoPropertiesWithAlbum:(NSString *)album artist:(NSString *)artist title:(NSString *)title {
    if (![self.album isEqualToString:album] ||
        ![self.artist isEqualToString:artist] ||
        ![self.title isEqualToString:title]) {
        
        self.album = album;
        self.artist = artist;
        self.title = title;

        [[NSNotificationCenter defaultCenter] postNotificationName:NowPlayingInfoNotification object:self];
    }
}

- (void)updateState {
    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(BOOL playing) {
        if (self.playing != playing) {
            self.playing = playing;
            [[NSNotificationCenter defaultCenter] postNotificationName:NowPlayingStateNotification object:self];
        }
    });
}

- (void)appDidChange:(NSNotification *)notification {
    [self updateApp];
}

- (void)infoDidChange:(NSNotification *)notification {
    [self updateInfo];
}

- (void)playingDidChange:(NSNotification *)notification {
    [self updateState];
}

@end
