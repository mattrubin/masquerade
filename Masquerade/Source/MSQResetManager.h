//
//  MSQResetManager.h
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import Foundation;


@protocol MSQResetManagerDelegate <NSObject>

- (void)terminateSession;
- (void)beginSession;

@end


@interface MSQResetManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<MSQResetManagerDelegate> delegate;
- (void)resetBrowser;

@end
