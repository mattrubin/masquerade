//
//  MSQResetManager.m
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQResetManager.h"


@implementation MSQResetManager

+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)requestReset
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Browser?" message:@"Are you sure you want to reset the browser? Your current page, cookies, cache, and browsing history will all be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    [alert show];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self resetBrowser];
    }
}


#pragma mark - Reset Logic

- (void)resetBrowser
{
    // Destroy any browsing session in progress
    id<MSQResetManagerDelegate> delegate = self.delegate;
    [delegate terminateSession];

    // Delete all cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }

    // Clear the cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    // Wipe the Caches, Cookies, and Preferences directories
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    for (NSURL *libraryURL in URLs) {
        NSURL *cachesURL = [libraryURL URLByAppendingPathComponent:@"Caches" isDirectory:YES];
        [self purgeDirectoryAtURL:cachesURL];

        NSURL *cookiesURL = [libraryURL URLByAppendingPathComponent:@"Cookies" isDirectory:YES];
        [self purgeDirectoryAtURL:cookiesURL];

        NSURL *preferencesURL = [libraryURL URLByAppendingPathComponent:@"Preferences" isDirectory:YES];
        [self purgeDirectoryAtURL:preferencesURL];
    }

    // Start a new browsing session
    [delegate beginSession];
}

- (BOOL)deleteDirectoryAtURL:(NSURL *)directoryURL
{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:directoryURL error:&error];

    if (error) {
        NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
        if ([underlyingError.domain isEqualToString:NSPOSIXErrorDomain]) {
            switch (underlyingError.code) {
                case 1: // Operation not permitted
                    return [self purgeDirectoryAtURL:directoryURL];
                case 2: // No such file or directory
                    return YES; // Failing to delete a nonexistent directory is a kind of success
                default:
                    break;
            }
        }
        NSLog(@"ERROR: %@", error);
        NSLog(@"UNDERLYING ERROR: %@", underlyingError);
    }

    return success;
}

- (BOOL)purgeDirectoryAtURL:(NSURL *)directoryURL
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryURL
                                                      includingPropertiesForKeys:nil
                                                                         options:0
                                                                           error:&error];
    if (error) {
        NSLog(@"ERROR PURGING DIRECTORY: %@", directoryURL);
        NSLog(@"ERROR: %@", error);
        return NO;
    }

    BOOL failed = NO;
    for (NSURL *childURL in contents) {
        BOOL success = [self deleteDirectoryAtURL:childURL];
        if (!success) {
            NSLog(@"FAILED TO DELETE: %@", childURL);
            failed = YES;
        }
    }

    return !failed;
}

@end
