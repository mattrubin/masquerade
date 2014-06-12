//
//  MSQSearchManager.m
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQSearchManager.h"


static NSString * const DEFAULT_SEARCH_FORMAT = @"https://next.duckduckgo.com/?q=%@";


@implementation MSQSearchManager

+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (NSURL *)urlForSearch:(NSString *)searchString
{
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (__bridge CFStringRef)(searchString),
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;=%"),
                                                                        kCFStringEncodingUTF8);

    return [NSURLComponents componentsWithString:[NSString stringWithFormat:DEFAULT_SEARCH_FORMAT, CFBridgingRelease(escapedString)]].URL;
}

@end
