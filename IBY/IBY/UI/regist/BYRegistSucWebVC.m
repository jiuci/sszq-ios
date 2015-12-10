//
//  BYRegistSucWebVC.m
//  IBY
//
//  Created by chenglei on 15/12/4.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYRegistSucWebVC.h"

#import "BYAppDelegate.h"
#import "BYHomeVC.h"

@interface BYRegistSucWebVC ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *url;

@end

@implementation BYRegistSucWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_ACCOUNT_REGISTSUC]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webView];

}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* preUrlStr = [request.URL absoluteString];
    if ([preUrlStr rangeOfString:SSZQURL_ACCOUNT_REGISTSUC].length > 0 ||
        [preUrlStr isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_ACCOUNT_REGISTSUC]]) {
        return YES;
    }
    
    // 直接跳转直接主页
    BYHomeVC* homeVC = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeVC;
    [homeVC.navigationController popToViewController:homeVC animated:NO];
    BYLog(@"注册成功界面销毁");
    return NO;

    
    // --------------暂时无用--------------
//    NSString* preUrlString = nil;
//    NSString* requestString = [request.URL absoluteString];
//    NSArray* urlPiece = [requestString componentsSeparatedByString:@"?"];
//    if (urlPiece.count > 0) {
//        preUrlString = urlPiece[0];
//        if ([preUrlString hasSuffix:@"/"]) {
//            preUrlString = [preUrlString substringToIndex:preUrlString.length - 1];
//        }
//    }
//    if (!preUrlString) {
//        return NO;
//    }
//    //    [iConsole log:@"%@",requestString];
//    [iConsole log:@"web is loading %@",requestString];
//
//    
//    if ([preUrlString rangeOfString:@"/share/income"].length > 0
//        || [preUrlString isEqualToString:@"http://sf.m.biyao.com/share/income.html"]) {
//
//        [self dismissViewControllerAnimated:NO completion:nil];
//        
//        BYHomeVC* homeVC = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeVC;
//        [homeVC.navigationController popToViewController:homeVC animated:NO];
////        [self loadBlank];
//        return NO;
//    }

    return YES;
}


- (void)setUrl:(NSString *)url {
    if (_url != url) {
        _url = url;
    }
}



@end
