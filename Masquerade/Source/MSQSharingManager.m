//
//  MSQSharingManager.m
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQSharingManager.h"
#import <OvershareKit/OvershareKit.h>


@implementation MSQSharingManager

+ (void)shareURL:(NSURL *)url fromViewController:(UIViewController *)viewController
{
    OSKShareableContent *sharableContent = [OSKShareableContent contentFromURL:url];

    NSArray *excludedTypes = @[// Exclude social networks (this is a private browser, after all)
                               OSKActivityType_API_AppDotNet,
                               OSKActivityType_iOS_Facebook,
                               OSKActivityType_iOS_Twitter,
                               OSKActivityType_API_GooglePlus,
                               OSKActivityType_API_500Pixels,
                               // Exclude services that require app-specific API keys
                               OSKActivityType_API_Pocket,
                               OSKActivityType_API_Readability,
                               // We'll add our own 1Password integration
                               OSKActivityType_URLScheme_1Password_Search,
                               OSKActivityType_URLScheme_1Password_Browser,
                               ];
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:sharableContent
                                                   presentingViewController:viewController
                                                                    options:@{OSKActivityOption_ExcludedTypes: excludedTypes}];
}

@end
