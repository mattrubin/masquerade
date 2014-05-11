//
//  MSQWebViewController.m
//  Masquerade
//
//  Created by Matt Rubin on 5/10/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQWebViewController.h"


@interface MSQWebViewController () <UIWebViewDelegate>

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
    self.webView.delegate = self;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [self updateToolbarButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://duckduckgo.com"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)updateToolbarButtons
{
    self.backButtonItem.enabled = self.webView.canGoBack;
    self.forwardButtonItem.enabled = self.webView.canGoForward;
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
    [self updateToolbarButtons];
    NSLog(@"Should?  %@", request);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self updateToolbarButtons];
    NSLog(@"Loading: %@", webView.request);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateToolbarButtons];
    NSLog(@"Loaded:  %@", webView.request);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self updateToolbarButtons];
    NSLog(@"Failed:  %@", webView.request);
}

@end
