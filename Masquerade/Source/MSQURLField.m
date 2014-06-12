//
//  MSQURLField.m
//  Masquerade
//
//  Created by Matt Rubin on 6/11/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQURLField.h"


@interface MSQURLField () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;

@end


@implementation MSQURLField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set up navigation bar
        self.urlField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
        self.urlField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.urlField.borderStyle = UITextBorderStyleRoundedRect;
        self.urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.urlField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.urlField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.urlField.keyboardType = UIKeyboardTypeWebSearch;
        self.urlField.returnKeyType = UIReturnKeyGo;
        self.urlField.enablesReturnKeyAutomatically = YES;
        self.urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.urlField.rightViewMode = UITextFieldViewModeUnlessEditing;
        self.urlField.delegate = self;
        [self addSubview:self.urlField];

        self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.stopButton setTitle:@"✖︎" forState:UIControlStateNormal];
        [self.stopButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self.stopButton addTarget:self action:@selector(stopLoading:) forControlEvents:UIControlEventTouchUpInside];

        self.reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.reloadButton setTitle:@"↻" forState:UIControlStateNormal];
        [self.reloadButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self.reloadButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;

    // TODO: Animated loading bar with webView.estimatedProgress
    self.urlField.backgroundColor = _loading ? self.tintColor : [UIColor whiteColor];
    self.urlField.rightView = _loading ? self.stopButton : self.reloadButton;
}

- (NSString *)text
{
    return self.urlField.text;
}

- (void)setText:(NSString *)text
{
    self.urlField.text = text;
}


#pragma mark - Actions

- (IBAction)stopLoading:(id)sender
{
    [self.delegate stopLoadingFromURLField:self];
}

- (IBAction)reload:(id)sender
{
    [self.delegate reloadFromURLField:self];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.delegate urlField:self didEnterText:textField.text];

    [textField resignFirstResponder];
    return NO;
}


@end
