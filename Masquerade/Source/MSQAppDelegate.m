//
//  MSQAppDelegate.m
//  Masquerade
//
//  Created by Matt Rubin on 5/10/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQAppDelegate.h"
#import "MSQWebViewController.h"
#import "MSQResetManager.h"


@interface MSQAppDelegate () <MSQResetManagerDelegate>

@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIViewController *maskViewController;

@end


@implementation MSQAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    // Set up the browser (ensuring we blow away any old session data left by mistake)
    [MSQResetManager sharedManager].delegate = self;
    [[MSQResetManager sharedManager] resetBrowser];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    // Shown the mask in place of the browser to prevent snapshotting of the current web page
    self.window.rootViewController = self.maskViewController;
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

    self.window.rootViewController = self.rootViewController;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    [[MSQResetManager sharedManager] resetBrowser];
}


#pragma mark - MSQResetManagerDelegate

- (void)terminateSession
{
    // Destroy any browsing session in progress
    self.rootViewController = nil;
    self.window.rootViewController = nil;
}

- (void)beginSession
{
    // Start a new browsing session
    self.rootViewController = [[UINavigationController alloc] initWithRootViewController:[MSQWebViewController new]];
    self.window.rootViewController = self.rootViewController;
}

@end
