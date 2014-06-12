//
//  MSQSharingManager.h
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import Foundation;


@interface MSQSharingManager : NSObject

+ (instancetype)sharedManager;

- (void)shareURL:(NSURL *)url fromViewController:(UIViewController *)viewController;

@end
