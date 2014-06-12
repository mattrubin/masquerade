//
//  MSQPasswordManager.m
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQPasswordManager.h"
#import <OvershareKit/OSKRPSTPasswordManagementAppService.h>


@implementation MSQPasswordManager

+ (BOOL)isAvailable
{
    return [OSKRPSTPasswordManagementAppService passwordManagementAppIsAvailable];
}

+ (void)requestPasswordForURL:(NSURL *)url
{
    if ([OSKRPSTPasswordManagementAppService passwordManagementAppIsAvailable]) {
        NSURL *passwordAppURL = [OSKRPSTPasswordManagementAppService passwordManagementAppCompleteURLForSearchQuery:url.host];
        [[UIApplication sharedApplication] openURL:passwordAppURL];
    }
}

@end
