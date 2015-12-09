  
//
//  BYHomeVC.m
//  IBY
//
//  Created by panShiyu on 14-9-10.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYHomeVC.h"

#import "BYBaseWebVC.h"
#import "BYWebView.h"

#import "BYStatusBar.h"

#import "BYMineVC.h"
#import "BYHomeService.h"

#import "BYHomeInfo.h"
#import "BYHomeInfoSimple.h"
#import "BYHomeFloorInfo.h"

//#import "MJRefresh.h"

#import "BYLinearScrollView.h"
#import "BYImageView.h"
//#import "MJRefreshHeaderView.h"

//#import "SDCycleScrollView.h"
#import "BYPoolNetworkView.h"

#import "BYIMViewController.h"

#import "BYThemeVC.h"

//#import "RESideMenu.h"
//#import "BYLeftMenuViewController.h"
#import "BYAppDelegate.h"

#import "BYWalletWebVC.h"
#import "BYRankWebVC.h"
#import "BYAppCenter.h"

#import "WXApi.h"
#import "WXApiObject.h"
#import "WebViewJavascriptBridge.h"

//#import "BYPushWebVC.h"
#import "BYNextWebVC.h"


@interface BYHomeVC ()<BYImageViewTapDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (nonatomic, strong) BYHomeService * service;
@property (nonatomic, strong) BYHomeInfo * info;
@property (nonatomic, strong) BYLinearScrollView * bodyView;
@property (nonatomic, strong) UIImageView* hasNewMessage;
@property (nonatomic, strong) BYPoolNetworkView* poolNetworkView;
@property (nonatomic, assign) BOOL isLoading;
//@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic, strong) UIWebView *shareWebView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;


@end
@implementation BYHomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupWebUI];

}

- (void)setupWebUI {
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.mutiSwitch];
//    self.commonWebVC = [BYCommonWebVC sharedCommonWebVC];
    [self.mutiSwitch mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@46);
        make.bottom.equalTo(self.view);
    }];
    _service = [[BYHomeService alloc]init];
    
    [self.navigationItem setTitle:@"分享有利"];
    
    _shareWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.height - 46 - 20)];
    _shareWebView.delegate = self;
    // 原必要：http://m.biyao.com/share/income.html
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME]];
    [_shareWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_shareWebView];
    
//    JumpToWebShareBlk(@"http://m.biyao.com/share/income.html", nil);
    
    _info = [BYHomeInfo loadInfo];
    [self reloadData];
    
    // 微信分享跳转
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_shareWebView
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



-(void)updateUI
{
//    if (!_info) {
//        return;
//    }
//    self.isLoading = YES;
//    _hasNewMessage.hidden = YES;
////    BYUser * user = [BYAppCenter sharedAppCenter].user; 
////    _hasNewMessage.hidden = user.messageNum == 0;
//    [_bodyView by_removeAllSubviews];
//    if (_info.bannerArray.count == 1) {
//        BYImageView * image = [[BYImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_WIDTH/ (float)_info.bannerWidth*_info.bannerHeight)];
//        BYHomeInfoSimple * simple = _info.bannerArray[0];
//        image.jumpURL = simple.link;
//        image.categoryId = simple.categoryID;
//        image.tapDelegate = self;
//        image.tag = simple.categoryID;
//        image.image = [UIImage imageNamed:@"bg_placeholder"];
//        [image setImageWithUrl:simple.imagePath placeholderName:@"bg_placeholder"];
//        [image addTapAction:@selector(onImagetap:) target:image];
//        [_bodyView by_addSubview:image paddingTop:0];
//    }else if (_info.bannerArray.count > 1){
//        NSMutableArray *imagesURL = [NSMutableArray array];
//        for (int i =0; i<_info.bannerArray.count; i++) {
//            BYHomeInfoSimple *simpe = _info.bannerArray[i];
//            [imagesURL addObject:[NSURL URLWithString:simpe.imagePath]];
//        }
//    }
//    for (int i = 0; i < _info.floorArray.count; i++) {
//        BYHomeFloorInfo *floorInfo = _info.floorArray[i];
//        if (floorInfo.title.length) {
//            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28)];
//            titleLabel.textAlignment = NSTextAlignmentCenter;
//            titleLabel.textColor = BYColorNav;
//            titleLabel.font = Font(18);
//            titleLabel.text = floorInfo.title;
//            [_bodyView by_addSubview:titleLabel paddingTop:16];
//        }
//        if (floorInfo.subtitle.length) {
//            UILabel *subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
//            subTitleLabel.textAlignment = NSTextAlignmentCenter;
//            subTitleLabel.textColor = BYColor333;
//            subTitleLabel.font = Font(14);
//            subTitleLabel.text = floorInfo.subtitle;
//            [_bodyView by_addSubview:subTitleLabel paddingTop:8];
//        }
//        
//        if (floorInfo.imgtitle.length) {
//            
//            BYImageView * image = [[BYImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ceil(_info.adImgTitleHeight *SCREEN_WIDTH / (float)_info.adImgTitleWidth*2)/2)];
////            NSLog(@"%@",image);
//            [image setImageWithUrl:floorInfo.imgtitle placeholderName:@"bg_placeholder"];
//            
//            [_bodyView by_addSubview:image paddingTop:14];
//        }else{
//            UIView * vv =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 14)];
////            vv.backgroundColor = [UIColor blackColor];
//            [_bodyView by_addSubview:vv paddingTop:0];
//        }
//        
//        for (int j = 0; j < floorInfo.adsArray.count;j++ ) {
//            
//            BYImageView * image = [[BYImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _info.adHeight * SCREEN_WIDTH / (float)_info.adWidth)];
//            //图片边界效果
////            UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 196)];
////            leftLineView.backgroundColor = HEXCOLOR(0xe8e8e8);
////            UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 32, 0, 1, 196)];
////            rightLineView.backgroundColor = HEXCOLOR(0xe8e8e8);
////            [image addSubview:leftLineView];
//            
////            [image addSubview:rightLineView];
//            
//            NSArray *adsArray = floorInfo.adsArray;
//            BYHomeInfoSimple * simple = adsArray[j];
//            image.categoryId = simple.categoryID;
//            image.jumpURL = simple.link;
//            image.tapDelegate = self;
//            [image setImageWithUrl:simple.imagePath placeholderName:@"bg_placeholder"];
//            [image addTapAction:@selector(onImagetap:) target:image];
//            [_bodyView by_addSubview:image paddingTop:0];
//        }
//    }
//    
//    
//    [self.mutiSwitch setSelectedAtIndex:0];
//    self.isLoading = NO;
}


-(void)reloadData
{
    if ([BYAppCenter sharedAppCenter].isNetConnected) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME]];
        [_shareWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }else {
        [MBProgressHUD topShowTmpMessage:@"网络异常，请检查您的网络"];
    }
}

#pragma mark -
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.mutiSwitch setSelectedAtIndex:0];
    
    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [MBProgressHUD topShowTmpMessage:@"  请先登录  "];
        __weak BYHomeVC *wself = self;
        BYLoginSuccessBlock successblock = ^(){
            [wself reloadData];
        };
        // loginVC
        [self presentViewController:makeLoginNavFromHome(successblock, nil) animated:NO completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
        
//        [self reloadData];
    }
    
    [self reloadData];
    
}
-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    
    
    addCookies(@"http://m.biyao.com/index", @"gobackuri", @".biyao.com");
    
//    addCookies(@"", @"gobackuri", @".biyao.com");
//    _needJumpUrl = @"http://ibuyfun.biyao.com/nvzhuang?f_upd-fa-114";
//    if ([_needJumpUrl hasPrefix:@"http://"]) {
//        [_commonWebVC.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_needJumpUrl]]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.navigationController pushViewController:_commonWebVC animated:YES];
//        });
//        _needJumpUrl = nil;
//    }
//    BYUser * user = [BYAppCenter sharedAppCenter].user;
//    _hasNewMessage.hidden = user.messageNum == 0;
//    [self.navigationController pushViewController:[BYCommonWebVC sharedCommonWebVC] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
    
}

#pragma mark -
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* requestString = [request.URL absoluteString];
    if ([requestString isEqualToString:[NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_HOME]]) {
        return YES;
    }
    
    if (![BYAppCenter sharedAppCenter].isNetConnected) {
        [MBProgressHUD topShowTmpMessage:@"网络异常，请检查您的网络"];
        return NO;
    }

    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [MBProgressHUD topShowTmpMessage:@"  请先登录  "];
        return NO;
    }
    BYNextWebVC *nextWebVC = [[BYNextWebVC alloc] init];
    nextWebVC.urlStr = [request.URL absoluteString];
    nextWebVC.isJumpFromTapAction = YES;
    nextWebVC.isHiddenNavBar = YES;
    [self.navigationController pushViewController:nextWebVC animated:YES];
    
    return NO;
}


#pragma mark -


- (void)loginAction
{
//    [self.navigationController presentViewController:makeLoginnav(nil,nil) animated:NO completion:nil];
    [self.navigationController pushViewController:makeLoginnav(nil,nil) animated:NO];
}

- (void)onMore
{
    JumpToWebBlk(@"http://home.biyao.com", nil);
}
- (void)onImagetap:(BYImageView*)sender
{
    
    if (sender.categoryId == 0) {
        JumpToWebBlk(sender.jumpURL, nil);
    }else{
        BYThemeVC * themeVC = [BYThemeVC sharedThemeWithId:sender.categoryId];
        themeVC.url = [NSString stringWithFormat:@"http://m.biyao.fu.theme:%d/",sender.categoryId];
        
        [self.navigationController pushViewController:themeVC animated:YES];
    }
    
}
- (void)onCelltap:(NSString*)link
{
//    NSLog(@"%@",link);
    if ([link hasPrefix:@"http"]) {
        JumpToWebBlk(link, nil);
        return;
    }else if (link.intValue > 1000 && link.intValue < 10000){
        BYThemeVC * themeVC = [BYThemeVC sharedThemeWithId:link.intValue];
        themeVC.url = [NSString stringWithFormat:@"http://m.biyao.fu.theme:%d/",link.intValue];
        [self.navigationController pushViewController:themeVC animated:YES];
    }
}
- (BYMutiSwitch*)mutiSwitch
{
    if (!_mutiSwitch) {
        _mutiSwitch = [[BYMutiSwitch alloc] initWithFrame:BYRectMake(0, 0, SCREEN_WIDTH, 46)];
        _mutiSwitch.backView.image = [[UIImage imageNamed:@"bg_tabbar"] resizableImage];
        
        __weak BYHomeVC* wself = self;
        
        UIButton* btn1 = [BYBarButton barBtnWithIcon:@"icon_home" hlIcon:@"icon_home_highlight" title:@"首页"];
        [btn1 setTitleColor:BYColorb768 forState:UIControlStateHighlighted|UIControlStateNormal];
        [_mutiSwitch addButtonWithBtn:btn1
                               handle:^(id sender) {
                                   [wself reloadData];
                                   [wself.mutiSwitch setSelectedAtIndex:0];
                               }];
        
        UIButton* btn2 = [BYBarButton barBtnWithIcon:@"icon_wallet" hlIcon:@"icon_wallet_highlight" title:@"钱包"];
        [btn2 setTitleColor:BYColorb768 forState:UIControlStateHighlighted];
        [_mutiSwitch addButtonWithBtn:btn2
                               handle:^(id sender) {
                                   [wself.navigationController pushViewController:[BYWalletWebVC sharedWalletWebVC] animated:NO];
                                   [wself.mutiSwitch setSelectedAtIndex:1];
                               }];
        
        UIButton* btn3 = [BYBarButton barBtnWithIcon:@"icon_rank" hlIcon:@"icon_rank_highlight" title:@"排行"];
        [btn3 setTitleColor:BYColorb768 forState:UIControlStateHighlighted];
        [_mutiSwitch addButtonWithBtn:btn3
                               handle:^(id sender) {
                                   [wself.navigationController pushViewController:[BYRankWebVC sharedRankWebVC] animated:NO];
                                   wself.navigationItem.hidesBackButton = YES;
                                   [wself.mutiSwitch setSelectedAtIndex:2];
                               }];

        
        UIButton* btn4 = [BYBarButton barBtnWithIcon:@"icon_mine" hlIcon:@"icon_mine_highlight" title:@"我的"];
        [btn3 setTitleColor:BYColorb768 forState:UIControlStateHighlighted];
        [_mutiSwitch addButtonWithBtn:btn4
                               handle:^(id sender) {
                                   [wself.navigationController pushViewController:[BYMineVC sharedMineVC] animated:NO];
                                   wself.navigationItem.hidesBackButton = YES;
                                   [wself.mutiSwitch setSelectedAtIndex:3];
                               }];
        
        [self.view addSubview:_mutiSwitch];
    }
    return _mutiSwitch;
}


- (void)refreshUIIfNeeded {

}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (self.navigationController.viewControllers.count == 1) {
//        return NO;
//    }
//    if ([self.navigationController.visibleViewController isEqual:self]||
//        [self.navigationController.visibleViewController isEqual:[BYCommonWebVC sharedCommonWebVC]]) {
//        return NO;
//    }
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    NSLog(@"%@",gestureRecognizer);
    return YES;
}
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event
//{
//    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
//        [self onAppShake];
//    }
//}





@end
