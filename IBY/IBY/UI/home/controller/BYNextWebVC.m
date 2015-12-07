//
//  BYNextWebVC.m
//  IBY
//
//  Created by chenglei on 15/12/4.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYNextWebVC.h"

@interface BYNextWebVC ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation BYNextWebVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self sutupUI];
}

- (void)sutupUI {
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]];
    if (_urlStr.length == 0 || !_urlStr) {
        _urlStr = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_ERROR];
    }

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
}


#pragma mark -
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (_isJumpFromTapAction) {
        NSString* requestString = [request.URL absoluteString];
        if ([requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME]] ||
            [requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_WALLET]] ||
            [requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]]) {
            
            [self.navigationController popViewControllerAnimated:YES];
            return NO;
        }
    }
    
    return YES;
}

@end
