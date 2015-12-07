//
//  BYRankWebVC.m
//  IBY
//
//  Created by chenglei on 15/12/2.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYRankWebVC.h"

#import "BYCommonWebVC.h"
#import "BYMineVC.h"
#import "BYWalletWebVC.h"

#import "BYNextWebVC.h"


@interface BYRankWebVC ()

@property (nonatomic, strong) UIWebView *webView;


@end

@implementation BYRankWebVC

+ (instancetype)sharedRankWebVC {
    static BYRankWebVC *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 46)];
    _webView.delegate = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mutiSwitch setSelectedAtIndex:2];
//    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES];
}


- (BYMutiSwitch*)mutiSwitch
{
    if (!_mutiSwitch) {
        _mutiSwitch = [[BYMutiSwitch alloc] initWithFrame:BYRectMake(0, SCREEN_HEIGHT  - 46, SCREEN_WIDTH, 46)];
        _mutiSwitch.backView.image = [[UIImage imageNamed:@"bg_tabbar"] resizableImage];
        
        __weak BYRankWebVC* wself = self;
        BYNavVC *wNavVC = (BYNavVC *)wself.navigationController;
        
        UIButton* btn1 = [BYBarButton barBtnWithIcon:@"icon_home" hlIcon:@"icon_home_highlight" title:@"首页"];
        [btn1 setTitleColor:BYColorb768 forState:UIControlStateHighlighted|UIControlStateNormal];
        [_mutiSwitch addButtonWithBtn:btn1
                               handle:^(id sender) {
                                   [wself.navigationController popToRootViewControllerAnimated:NO];
                                   [wself.mutiSwitch setSelectedAtIndex:0];
                               }];
        
        UIButton* btn2 = [BYBarButton barBtnWithIcon:@"icon_wallet" hlIcon:@"icon_wallet_highlight" title:@"钱包"];
        [btn2 setTitleColor:BYColorb768 forState:UIControlStateHighlighted];
        [_mutiSwitch addButtonWithBtn:btn2
                               handle:^(id sender) {
                                   if ([wNavVC viewControllersExistVC:[BYWalletWebVC class] WithVCs:wNavVC.viewControllers]) {
                                       [wself.navigationController popToViewController:[BYWalletWebVC sharedWalletWebVC] animated:NO];
                                   }else {
                                       [wself.navigationController pushViewController:[BYWalletWebVC sharedWalletWebVC] animated:NO];
                                   }
                                   wself.navigationItem.hidesBackButton = YES;
                                   [wself.mutiSwitch setSelectedAtIndex:1];
                               }];
        
        UIButton* btn3 = [BYBarButton barBtnWithIcon:@"icon_rank" hlIcon:@"icon_rank_highlight" title:@"排行"];
        [btn3 setTitleColor:BYColorb768 forState:UIControlStateHighlighted];
        [_mutiSwitch addButtonWithBtn:btn3
                               handle:^(id sender) {
                                   [wself reloadData];
                                   [wself.mutiSwitch setSelectedAtIndex:2];
                               }];

        
        UIButton* btn4 = [BYBarButton barBtnWithIcon:@"icon_mine" hlIcon:@"icon_mine_highlight" title:@"我的"];
        [btn4 setTitleColor:BYColorb768 forState:UIControlStateHighlighted];
        [_mutiSwitch addButtonWithBtn:btn4
                               handle:^(id sender) {
                                   if ([wNavVC viewControllersExistVC:[BYMineVC class] WithVCs:wNavVC.viewControllers]) {
                                       [wself.navigationController popToViewController:[BYMineVC sharedMineVC] animated:NO];
                                   }else {
                                       [wself.navigationController pushViewController:[BYMineVC sharedMineVC] animated:NO];
                                   }
                                   wself.navigationItem.hidesBackButton = YES;
                                   [wself.mutiSwitch setSelectedAtIndex:3];
                               }];
        
        [self.view addSubview:_mutiSwitch];
    }
    return _mutiSwitch;
}


-(void)reloadData {
    if ([BYAppCenter sharedAppCenter].isNetConnected) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }else{
        [MBProgressHUD topShowTmpMessage:@"网络异常，请检查您的网络"];
    }
    
}


#pragma mark -
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* requestString = [request.URL absoluteString];
    if ([requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_RANK]] ) {
        return YES;
    }
    
    if (![BYAppCenter sharedAppCenter].isNetConnected) {
        [MBProgressHUD topShowTmpMessage:@"网络异常，请检查您的网络"];
        return NO;
    }
    
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [MBProgressHUD topShowTmpMessage:@"  请先登录  "];
        return NO;
    }

    BYNextWebVC *nextWebVC = [[BYNextWebVC alloc] init];
    nextWebVC.urlStr = [request.URL absoluteString];
    nextWebVC.isJumpFromTapAction = YES;
    [self.navigationController pushViewController:nextWebVC animated:YES];
    
    return NO;
}


@end
