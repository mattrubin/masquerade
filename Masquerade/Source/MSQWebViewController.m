//
//  MSQWebViewController.m
//  Masquerade
//
//  Created by Matt Rubin on 5/10/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQWebViewController.h"
#import "MSQURLInterpreter.h"
#import "MSQSharingManager.h"
#import "MSQPasswordManager.h"


NSString * const MSQResetBrowserNotification = @"MSQResetBrowserNotification";

static NSString * const DEFAULT_SCHEME = @"http";
static NSString * const DEFAULT_SEARCH_FORMAT = @"https://next.duckduckgo.com/?q=%@";

static NSString * const kURLKeyPath = @"webView.URL";
static NSString * const kLoadingKeyPath = @"webView.loading";


@interface MSQWebViewController () <WKNavigationDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardButtonItem;
@property (nonatomic, strong) UIBarButtonItem *resetButtonItem;
@property (nonatomic, strong) UIBarButtonItem *shareButtonItem;
@property (nonatomic, strong) UIBarButtonItem *passwordButtonItem;

@property (nonatomic, strong) NSString *searchTerm;

@end


@implementation MSQWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.backButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack)];
        self.forwardButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward)];
        self.resetButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(resetBrowser)];
        self.shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];

        [self addObserver:self forKeyPath:kURLKeyPath options:0 context:nil];
        [self addObserver:self forKeyPath:kLoadingKeyPath options:0 context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kURLKeyPath]) {
        self.urlField.text = self.webView.URL.absoluteString;
        self.shareButtonItem.enabled = !!self.webView.URL.absoluteString.length;
        self.passwordButtonItem.enabled = !!self.webView.URL.absoluteString.length;
    } else if ([keyPath isEqualToString:kLoadingKeyPath]) {
        // TODO: Animated loading bar with webView.estimatedProgress
        self.urlField.backgroundColor = self.webView.isLoading ? self.view.tintColor : [UIColor whiteColor];
        self.urlField.rightView = self.webView.isLoading ? self.stopButton : self.reloadButton;
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kURLKeyPath];
    [self removeObserver:self forKeyPath:kLoadingKeyPath];
}

- (void)loadView
{
    self.webView = [WKWebView new];
    self.webView.navigationDelegate = self;
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
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[self.resetButtonItem,
                          flexibleSpace,
                          self.backButtonItem,
                          flexibleSpace,
                          self.forwardButtonItem,
                          flexibleSpace,
                          self.shareButtonItem];

    if ([MSQPasswordManager isAvailable]) {
        self.passwordButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"🔑" style:UIBarButtonItemStylePlain target:self action:@selector(helpWithPassword)];
        self.toolbarItems = @[self.resetButtonItem,
                              flexibleSpace,
                              self.backButtonItem,
                              flexibleSpace,
                              self.forwardButtonItem,
                              flexibleSpace,
                              self.passwordButtonItem,
                              flexibleSpace,
                              self.shareButtonItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.toolbarHidden = NO;
    [self updateButtonsForWebView:self.webView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.webView.URL) {
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://next.duckduckgo.com"]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)updateButtonsForWebView:(WKWebView *)webView
{
    self.backButtonItem.enabled = webView.canGoBack;
    self.forwardButtonItem.enabled = webView.canGoForward;
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

- (void)resetBrowser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Browser?" message:@"Are you sure you want to reset the browser? Your current page, cookies, cache, and browsing history will all be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    [alert show];
}

- (void)share
{
    [MSQSharingManager shareURL:self.webView.URL fromViewController:self];
}

- (void)helpWithPassword
{
    [MSQPasswordManager requestPasswordForURL:self.webView.URL];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MSQResetBrowserNotification object:self];
    }
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self updateButtonsForWebView:webView];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *urlString = [MSQURLInterpreter urlStringFromInput:textField.text];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];

    // If no scheme has been specified, use HTTP
    if (!components.scheme) components.scheme = DEFAULT_SCHEME;

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:components.URL];
    [self.webView loadRequest:request];

    // Cache the input in case we need it for searching
    self.searchTerm = textField.text;

    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Search

- (void)searchForString:(NSString *)searchString
{
    NSURLComponents *components = [self urlComponentsForSearch:searchString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:components.URL];
    [self.webView loadRequest:request];
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
