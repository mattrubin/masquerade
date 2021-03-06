//
//  MSQURLField.m
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQURLField.h"


@interface MSQURLField () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIProgressView *progressBar;

@end


@implementation MSQURLField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [UITextField new];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.textField.keyboardType = UIKeyboardTypeWebSearch;
        self.textField.returnKeyType = UIReturnKeyGo;
        self.textField.enablesReturnKeyAutomatically = YES;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.rightViewMode = UITextFieldViewModeUnlessEditing;
        self.textField.delegate = self;
        [self addSubview:self.textField];

        self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.stopButton setTitle:@"✖︎" forState:UIControlStateNormal];
        [self.stopButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self.stopButton addTarget:self action:@selector(stopLoading:) forControlEvents:UIControlEventTouchUpInside];

        self.reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.reloadButton setTitle:@"↻" forState:UIControlStateNormal];
        [self.reloadButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self.reloadButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];

        self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [self addSubview:self.progressBar];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.textField.frame = self.bounds;

    [self.progressBar sizeToFit];
    CGRect progressFrame = self.progressBar.frame;
    progressFrame.size.width = CGRectGetWidth(self.bounds);
    progressFrame.origin.x = CGRectGetMinX(self.bounds);
    progressFrame.origin.y = CGRectGetMaxY(self.bounds) - CGRectGetHeight(progressFrame);
    self.progressBar.frame = progressFrame;
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}


#pragma mark - Properties

- (void)setLoading:(BOOL)loading
{
    _loading = loading;

    self.progressBar.hidden = !_loading;
    self.textField.rightView = _loading ? self.stopButton : self.reloadButton;
}

- (void)setPercentLoaded:(double)percentLoaded
{
    _percentLoaded = percentLoaded;

    self.progressBar.progress = (float)_percentLoaded;
}

- (NSString *)text
{
    return self.textField.text;
}

- (void)setText:(NSString *)text
{
    self.textField.text = text;
}


#pragma mark - Actions

- (IBAction)stopLoading:(id)sender
{
    id<MSQURLFieldDelegate> delegate = self.delegate;
    [delegate stopLoadingFromURLField:self];
}

- (IBAction)reload:(id)sender
{
    id<MSQURLFieldDelegate> delegate = self.delegate;
    [delegate reloadFromURLField:self];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    id<MSQURLFieldDelegate> delegate = self.delegate;
    [delegate urlField:self didEnterText:textField.text];

    [textField resignFirstResponder];
    return NO;
}

@end
