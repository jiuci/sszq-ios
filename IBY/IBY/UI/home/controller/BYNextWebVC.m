//
//  BYNextWebVC.m
//  IBY
//
//  Created by chenglei on 15/12/4.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYNextWebVC.h"
#import "BYIdcardVC.h"

#import "WXApi.h"
#import "WXApiObject.h"
#import "WebViewJavascriptBridge.h"
#import "BYWebView.h"


@interface BYNextWebVC ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;
@property (nonatomic, assign) BOOL isJumpToIdcardVC;


@end

@implementation BYNextWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self sutupUI];

    if (_isHiddenNavBar) {
        self.navigationController.navigationBarHidden = YES;
    }

}

- (void)sutupUI {
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // 微信分享跳转
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView
                                        webViewDelegate:self
                                                handler:^(id data, WVJBResponseCallback responseCallback) {
                                                    if (![data isKindOfClass:[NSDictionary class]]) {
                                                        return;
                                                    }
                                                    BYH5Unit* unit = [BYH5Unit unitWithH5Info:data];
                                                    if (unit) {
                                                        [unit runFromVC:self];
                                                    }
                                                }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]];
    if (_urlStr.length == 0 || !_urlStr) {
        _urlStr = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_ERROR];
    }
    
    if (!_isJumpToIdcardVC) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    }
    
    if (_isHiddenNavBar) {
        self.navigationController.navigationBarHidden = YES;
    }
}



#pragma mark -
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* requestString = [request.URL absoluteString];
    // 返回
    if (_isJumpFromTapAction) {
        NSString *homeUrl = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME];
        NSString *walletUrl = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_WALLET];
        NSString *rankUrl = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK];
        if ([requestString rangeOfString:homeUrl].length > 0 ||
            [requestString rangeOfString:walletUrl].length > 0 ||
            [requestString rangeOfString:rankUrl].length > 0) {
            
            [self.navigationController popViewControllerAnimated:YES];
            return NO;
        }

//        if ([requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME]] ||
//            [requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_WALLET]] ||
//            [requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]]
//            ) {
//            
//            [self.navigationController popViewControllerAnimated:YES];
//            return NO;
//        }
    }
    
#warning SSZQ0-TEST----------NEEDDO
    //  SSZQURL_MINE : @"/account/mine" --》@"/account/mine.html"
    if (_isJumpFromTapAction) {
        NSString *mineUrl = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_MINE];
        if ([requestString rangeOfString:mineUrl].length > 0) {
            [self.navigationController popViewControllerAnimated:NO];
            return NO;
        }
    }
    
    // 跳转上传身份证
    NSString *sfzUrl = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_USER_SHARESFZ];
    if ([requestString rangeOfString:sfzUrl].length > 0) {
        self.isJumpToIdcardVC = YES;
        [self.navigationController pushViewController:[[BYIdcardVC alloc] init] animated:NO];
        return NO;
    }
    
    return YES;
}

@end
