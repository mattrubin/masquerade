//
//  MSQWebViewController.m
//  Masquerade
//
//  Created by Matt Rubin on 5/10/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQWebViewController.h"
#import "MSQURLInterpreter.h"


static NSString * const DEFAULT_SCHEME = @"http";
static NSString * const DEFAULT_SEARCH_FORMAT = @"https://duckduckgo.com/?q=%@";


@interface MSQWebViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardButtonItem;

@end


@implementation MSQWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    self.navigationItem.titleView = self.urlField;

    self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self.stopButton setTitle:@"✖︎" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];

    self.reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self.reloadButton setTitle:@"↻" forState:UIControlStateNormal];
    [self.reloadButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.reloadButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];

    // Set up toolbar
    self.backButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack)];
    self.forwardButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[flexibleSpace, self.backButtonItem, flexibleSpace, self.forwardButtonItem, flexibleSpace];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.toolbarHidden = NO;
    [self updateButtonsForWebView:self.webView];
    [self updateURLField];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.webView.request) {
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://duckduckgo.com"]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)updateURLField
{
    self.urlField.text = self.webView.request.URL.absoluteString;
}

- (void)updateButtonsForWebView:(UIWebView *)webView
{
    self.backButtonItem.enabled = webView.canGoBack;
    self.forwardButtonItem.enabled = webView.canGoForward;
    self.urlField.backgroundColor = webView.isLoading ? self.view.tintColor : [UIColor whiteColor];
    self.urlField.rightView = webView.isLoading ? self.stopButton : self.reloadButton;
}

- (void)stopLoading
{
    [self.webView stopLoading];
}

- (void)reload
{
    [self.webView reload];
}

- (void)goBack
{
    [self.webView goBack];
}

- (void)goForward
{
    [self.webView goForward];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // We don't update the URL field here because the request might be for some widget embedded in the larger page
    [self updateButtonsForWebView:webView];

    NSLog(@"Should Load? %@", request.URL);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // We don't update the URL field here because webView.request might still hold the request for the previous page
    [self updateButtonsForWebView:webView];

    NSLog(@"Loading...");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateURLField];
    [self updateButtonsForWebView:webView];

    NSLog(@"Loaded.");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self updateURLField];
    [self updateButtonsForWebView:webView];

    NSLog(@"Failed: %@ (%@)", error.localizedDescription, error.userInfo[NSURLErrorFailingURLErrorKey]);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *urlString = [MSQURLInterpreter urlStringFromInput:textField.text];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];

    // If no host is specified, treat this as a search
//    if (!components.host)
//        components = [self urlComponentsForSearch:textField.text]; // search for the unescaped string

    // If no scheme has been specified, use HTTP
    if (!components.scheme) components.scheme = DEFAULT_SCHEME;

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:components.URL];
    [self.webView loadRequest:request];

    [textField resignFirstResponder];
    return NO;
}

- (NSURLComponents *)urlComponentsForSearch:(NSString *)searchString
{
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (__bridge CFStringRef)(searchString),
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;=%"),
                                                                        kCFStringEncodingUTF8);

    return [NSURLComponents componentsWithString:[NSString stringWithFormat:DEFAULT_SEARCH_FORMAT, CFBridgingRelease(escapedString)]];
}

@end
