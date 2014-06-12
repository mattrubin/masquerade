//
//  MSQURLField.h
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import UIKit;


@protocol MSQURLFieldDelegate;


@interface MSQURLField : UIView

@property (nonatomic, weak) id<MSQURLFieldDelegate> delegate;

@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic) double percentLoaded;
@property (nonatomic, copy) NSString *text;

@end


@protocol MSQURLFieldDelegate <NSObject>

- (void)urlField:(MSQURLField *)urlField didEnterText:(NSString *)string;
- (void)stopLoadingFromURLField:(MSQURLField *)urlField;
- (void)reloadFromURLField:(MSQURLField *)urlField;

@end
