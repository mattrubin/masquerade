//
//  MSQWebViewController.h
//  Masquerade
//
//  Created by Matt Rubin on 5/10/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import UIKit;
@import WebKit;


extern NSString * const MSQResetBrowserNotification;


@interface MSQWebViewController : UIViewController

@property (nonatomic, strong) WKWebView *webView;

@end
