//
//  MSQPasswordManager.h
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import Foundation;


@interface MSQPasswordManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)isAvailable;
- (void)requestPasswordForURL:(NSURL *)url;

@end
