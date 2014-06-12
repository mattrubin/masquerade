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
#import "MSQSearchManager.h"
#import "MSQResetManager.h"
#import "MSQURLField.h"


static NSString * const DEFAULT_SCHEME = @"http";

static NSString * const kURLKeyPath = @"webView.URL";
static NSString * const kLoadingKeyPath = @"webView.loading";


@interface MSQWebViewController () <WKNavigationDelegate, MSQURLFieldDelegate>

@property (nonatomic, strong) MSQURLField *urlField;
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
        self.urlField.loading = self.webView.isLoading;
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kURLKeyPath];
    [self removeObserver:self forKeyPath:kLoadingKeyPath];
}


#pragma mark - View Lifecycle

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
    self.urlField = [[MSQURLField alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
    self.urlField.delegate = self;
    self.navigationItem.titleView = self.urlField;

    // Set up toolbar
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[self.resetButtonItem,
                          flexibleSpace,
                          self.backButtonItem,
                          flexibleSpace,
                          self.forwardButtonItem,
                          flexibleSpace,
                          self.shareButtonItem];

    if ([[MSQPasswordManager sharedManager] isAvailable]) {
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.webView.URL) {
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://next.duckduckgo.com"]]];
    }
}


#pragma mark - Actions

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
    [[MSQResetManager sharedManager] requestReset];
}

- (void)share
{
    [[MSQSharingManager sharedManager] shareURL:self.webView.URL fromViewController:self];
}

- (void)helpWithPassword
{
    [[MSQPasswordManager sharedManager] requestPasswordForURL:self.webView.URL];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.backButtonItem.enabled = webView.canGoBack;
    self.forwardButtonItem.enabled = webView.canGoForward;
}


#pragma mark - MSQURLFieldDelegate

- (void)urlField:(MSQURLField *)urlField didEnterText:(NSString *)string
{
    NSString *urlString = [MSQURLInterpreter urlStringFromInput:string];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];

    // If no scheme has been specified, use HTTP
    if (!components.scheme) components.scheme = DEFAULT_SCHEME;

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:components.URL];
    [self.webView loadRequest:request];

    // Cache the input in case we need it for searching
    self.searchTerm = string;
}

- (void)stopLoadingFromURLField:(MSQURLField *)urlField
{
    [self.webView stopLoading];
}

- (void)reloadFromURLField:(MSQURLField *)urlField
{
    [self.webView reload];
}

@end
