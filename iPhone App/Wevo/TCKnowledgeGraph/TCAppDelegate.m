//
//  TCAppDelegate.m
//  TCKnowledgeGraph
//
//  Created by Lee Tze Cheun on 6/12/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCAppDelegate.h"
#import "PlayerEventLogger.h"

@implementation TCAppDelegate

@synthesize window = _window;

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PlayVideoInBackground"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerViewControllerDidReceiveVideo:) name:XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification object:nil];
    
    [[PlayerEventLogger sharedLogger] setEnabled:YES];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notifications

- (void) videoPlayerViewControllerDidReceiveVideo:(NSNotification *)notification
{
    XCDYouTubeVideo *video = notification.userInfo[XCDYouTubeVideoUserInfoKey];
    NSString *title = video.title;
    if (title)
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{ MPMediaItemPropertyTitle: title };
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:video.mediumThumbnailURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data)
        {
            UIImage *image = [UIImage imageWithData:data];
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
            if (title && artwork)
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{ MPMediaItemPropertyTitle: title, MPMediaItemPropertyArtwork: artwork };
        }
    }];
}

@end
