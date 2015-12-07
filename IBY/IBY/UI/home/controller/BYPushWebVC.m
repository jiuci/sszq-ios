//
//  BYPushWebVC.m
//  IBY
//
//  Created by chenglei on 15/12/3.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYPushWebVC.h"

@interface BYPushWebVC ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation BYPushWebVC


- (void)viewDidLoad {
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20)];
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
    
    //    [self checkNetConnected];
    
    NSString* requestString = [request.URL absoluteString];
    BYLog(@"requestString : %@", requestString);
    if ([requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME]] ||
        [requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_WALLET]] ||
        [requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]] ||
        [requestString containsString:@"index"]) {
        
#warning SSZZ-TEST-----------NEEDDO
        // 模态VC模拟pop
//        CATransition *popAnimaton = [CATransition animation];
//        popAnimaton.duration = 0.5;
//        popAnimaton.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        popAnimaton.type = kCATransitionFade;
//        popAnimaton.subtype = kCATransitionFromTop;
////        popAnimation.delegate = self;
////        popAnimation.duration = 0.5;
//
//        [self.view.layer addAnimation:popAnimaton forKey:@"pushedBackAnimation"];

//        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:^{
//            [UIView animateWithDuration:0.5 animations:^{
//                self.view.transform = CGAffineTransformMakeTranslation(-SCREEN_WIDTH, 0.0);
//            }];
        }];
        return NO;
        
    }
    
    return YES;
}




@end
