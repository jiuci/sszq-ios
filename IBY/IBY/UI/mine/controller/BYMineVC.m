//
//  BYMinewVC.m
//  IBY
//
//  Created by coco on 14-9-13.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYMineVC.h"
#import "BYLoginVC.h"

#import "BYMineHeaderView.h"
#import "BYLinearScrollView.h"

#import "BYMineCell.h"

#import "BYRegist1VC.h"
//#import "BYOrderlistVC.h"
//#import "BYMyDesignsVC.h"
#import "BYSettingVC.h"
//#import "BYMessageVC.h"
#import "BYAboutVC.h"
//#import "BYMyDesignsVC.h"
#import "BYAddressManagelistVC.h"
#import "BYUserService.h"
//#import "BYOrder.h"

//#import "BYCaptureVC.h"
//#import "BYGlassPageVC.h"

#import "BYBarButtonItem.h"
#import "BYCommonWebVC.h"

#import "BYAvatarSettingVC.h"
//#import "BYtest.h"

#import "BYWalletWebVC.h"
#import "BYRankWebVC.h"

#import "BYIdcardVC.h"


@interface BYMineVC ()
@property (nonatomic, strong) BYLinearScrollView* bodyView;
@property (nonatomic, strong) BYMineHeaderView* headerView;
@property (nonatomic, strong) BYUserService* service;
@end

@implementation BYMineVC
+ (instancetype)sharedMineVC
{
    static BYMineVC* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    _service = [[BYUserService alloc] init];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"个人中心";
    [self.mutiSwitch setSelectedAtIndex:3];
    BOOL isLogin = checkLoginCookies();
    if (!isLogin) {
        [[BYAppCenter sharedAppCenter] logout];
    }
    addCookies(BYURL_MINE, @"gobackuri", @".biyao.com");
    //    addCookies(BYURL_MINE, @"gobackuri", @"m.biyao.com");
    
    
    [self updateUI];
    [self updateData];

    
}

- (void)viewDidAppear:(BOOL)animated
{
}


- (void)viewWillDisappear:(BOOL)animated
{
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [super viewWillDisappear:animated];
}
- (void)updateData
{
    if ([BYAppCenter sharedAppCenter].isLogin) {
        [_service fetchUserLatestStatus:^(BOOL isSuccess, BYError* error) {
            if (isSuccess) {
                [self updateUI];
            }else{
                alertError(error);
            }
        }];
    }
}

- (void)updateUI
{
    [self.headerView updateUI];
    [MBProgressHUD topHide];
    _hasNewMessage.hidden = YES;
    BYUser * user = [BYAppCenter sharedAppCenter].user;
    _hasNewMessage.hidden = user.messageNum == 0;
    
}

- (void)setupUI
{
    //nav
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithImgName:@"btn_meassages" highImgName:@"btn_meassages" handler:^(id sender) {
//        if (![BYAppCenter sharedAppCenter].isLogin) {
//            [self loginAction];
//            return;
//        }
//        JumpToWebBlk(@"http://m.biyao.com/message", nil);
//    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]init];
    
    _hasNewMessage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
    
    _hasNewMessage.image = [UIImage imageNamed:@"bg_messages_hasmessage"];
    [self.navigationItem.rightBarButtonItem.customView addSubview:_hasNewMessage];
    _hasNewMessage.right = _hasNewMessage.superview.width + 5;
    _hasNewMessage.bottom = _hasNewMessage.superview.height / 2 - 4;
//    _hasNewMessage.hidden = YES;
    
    
    _bodyView = [[BYLinearScrollView alloc] initWithFrame:BYRectMake(0, 0, self.view.width, self.view.height - self.navigationController.navigationBar.height - 46 - [[UIApplication sharedApplication] statusBarFrame].size.height)];
//    _bodyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bodyView.autoAdjustContentSize = NO;
    _bodyView.minContentSizeHeight = 0;
    [self.view addSubview:_bodyView];

    _headerView = [BYMineHeaderView headerView];
    [_headerView setupUI];
    _headerView.mineVC = self;
    
    [self.bodyView by_addSubview:_headerView paddingTop:0];

//    [self appendCell:@"icon_usercenter_share"
//               title:@"分享有利"
//                 top:12
//                 sel:@selector(onShare)];
    
//    [self appendCell:@"icon_usercenter_orderinquiry"
//               title:@"我的订单"
//                 top:0
//                 sel:@selector(onOrders)];
    
//    [self appendCell:@"icon_usercenter_book"
//               title:@"我的预约"
//                 top:0
//                 sel:@selector(onMybook)];
    
//    [self appendCell:@"icon_usercenter_wallet"
//               title:@"我的钱包"
//                 top:0
//                 sel:@selector(onWallet)];

//    [self appendCell:@"icon_usercenter_mydesign"
//               title:@"我的作品集"
//                 top:0
//                 sel:@selector(onMydesign)];
    
//    [self appendCell:@"icon_usercenter_coupon"
//               title:@"我的红包"
//                 top:0
//                 sel:@selector(onMycoupon)];
    
//    [self appendCell:@"icon_usercenter_address"
//               title:@"我的地址"
//                 top:0
//                 sel:@selector(onAdress)];
    
//    [self appendCell:@"icon_usercenter_addressadmin"
//               title:@"退款管理"
//                 top:0
//                 sel:@selector(onAdress)];

    [self appendCell:@"icon_usercenter_service"
               title:@"客服中心"
                 top:12
                 sel:@selector(onService)];
    
    [self appendCell:@"icon_usercenter_setting"
               title:@"设置"
                 top:0
                 sel:@selector(onSetting)];
    
    [self.bodyView by_addSubview:[[UIView alloc]init] paddingTop:12];
    
    
//    [self appendCell:@"icon_usercenter_setting"
//               title:@"相机"
//                 top:12
//                 sel:@selector(onCamera)];
//    
//    [self appendCell:@"icon_usercenter_setting"
//               title:@"pageView"
//                 top:12
//                 sel:@selector(pageScroll)];
    
//    [self appendCell:@"icon_usercenter_setting"
//               title:@"测试-相册上传"
//                 top:12
//                 sel:@selector(onIdcard)];

    
    [self.view addSubview:self.mutiSwitch];
    
    [self.mutiSwitch mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@46);
        make.bottom.equalTo(self.view);
    }];
    
    
}
- (BYMutiSwitch*)mutiSwitch
{
    if (!_mutiSwitch) {
        _mutiSwitch = [[BYMutiSwitch alloc] initWithFrame:BYRectMake(0, 0, SCREEN_WIDTH, 46)];
        _mutiSwitch.backView.image = [[UIImage imageNamed:@"bg_tabbar"] resizableImage];
        
        __weak BYMineVC* wself = self;
        BYNavVC *wNavVC = (BYNavVC *)wself.navigationController;
        
        UIButton* btn1 = [BYBarButton barBtnWithIcon:@"icon_home" hlIcon:@"icon_home_highlight" title:@"首页"];
        [_mutiSwitch addButtonWithBtn:btn1
                               handle:^(id sender) {
                                   [wself.navigationController popToRootViewControllerAnimated:NO];
                                   [wself.mutiSwitch setSelectedAtIndex:0];
                               }];
        
        UIButton* btn2 = [BYBarButton barBtnWithIcon:@"icon_wallet" hlIcon:@"icon_wallet_highlight" title:@"钱包"];
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
        [_mutiSwitch addButtonWithBtn:btn3
                               handle:^(id sender) {
                                   if ([wNavVC viewControllersExistVC:[BYRankWebVC class] WithVCs:wNavVC.viewControllers]) {
                                       [wself.navigationController popToViewController:[BYRankWebVC sharedRankWebVC] animated:NO];
                                   }else {
                                       [wself.navigationController pushViewController:[BYRankWebVC sharedRankWebVC] animated:NO];
                                   }
                                   wself.navigationItem.hidesBackButton = YES;
                                   [wself.mutiSwitch setSelectedAtIndex:2];
                               }];
        
        UIButton* btn4 = [BYBarButton barBtnWithIcon:@"icon_mine" hlIcon:@"icon_mine_highlight" title:@"我的"];
        [_mutiSwitch addButtonWithBtn:btn4
                               handle:^(id sender) {
                                   //再进我的必要就不响应了
                                   [wself.mutiSwitch setSelectedAtIndex:3];
                               }];
        
        [self.view addSubview:_mutiSwitch];
    }
    return _mutiSwitch;
}
- (void)appendCell:(NSString*)icon title:(NSString*)title top:(CGFloat)top sel:(SEL)selecor
{
    BYMineCell* cell = [BYMineCell cellWithTitle:title icon:icon target:self sel:selecor];
    [self.bodyView by_addSubview:cell paddingTop:top];
    
}

#pragma mark -

- (void)onIdcard {
//    BYIdcardVC *idcardVC = [[BYIdcardVC alloc] init];
//    [self.navigationController pushViewController:idcardVC animated:YES];
}

- (void)pageScroll{
//    
//    BYtest* test = [[BYtest alloc] init];
//    [test detectEyes];
}

- (void)onCamera
{
//
//    
//    NSString* glassCache = @"glassCache";
//    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:glassCache];
//    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//
//    if(array.count == 0){
//        BYCaptureVC* capVC = [[BYCaptureVC alloc] init];
//        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:capVC];
//        [self presentViewController:nav animated:YES completion:^{
//        }];
//    }else{
//        BYGlassPageVC* pageVC = [[BYGlassPageVC alloc]init];
//        [self.navigationController pushViewController:pageVC animated:YES];
//    }
}


- (void)onWallet
{
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/share/money.html", nil);
}

- (void)onShare
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/share/income.html", nil);
}

- (void)onMycoupon
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/money/money", nil);
}

- (void)onMybook
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/book/index.html", nil);
}


- (void)onMydesign
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/account/myworks", nil);
}

- (void)onAdress
{
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    BYAddressManagelistVC *vc = [[BYAddressManagelistVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//
}

- (void)onOrders
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/order/orderlist", nil);
}

- (void)onToPayOrders
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
////    if ([BYAppCenter sharedAppCenter].user.notPayOrderNum == 0) {
////        [MBProgressHUD topShowTmpMessage:@"您还没有待付款订单"];
////        return;
////    }
//    JumpToWebBlk(@"http://m.biyao.com/order/orderlist?orderStatus=1", nil);
//
//    
}

- (void)onInProcessOrders
{
//
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
//    JumpToWebBlk(@"http://m.biyao.com/order/orderlist?orderStatus=3", nil);
}

- (void)onInRefundOrders
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
////    if ([BYAppCenter sharedAppCenter].user.refundNum == 0) {
////        [MBProgressHUD topShowTmpMessage:@"您还没有退款/售后订单"];
////        return;
////    }
//    
//    JumpToWebBlk(@"http://m.biyao.com/refund/myrefund", nil);
}

- (void)onToDeliverConfirmOrders
{
//
//    if (![BYAppCenter sharedAppCenter].isLogin) {
//        [self loginAction];
//        return;
//    }
////    if ([BYAppCenter sharedAppCenter].user.toReceiveOrderNum == 0) {
////        [MBProgressHUD topShowTmpMessage:@"您还没有待收货订单"];
////        return;
////    }
//    JumpToWebBlk(@"http://m.biyao.com/order/orderlist?orderStatus=4", nil);
}

- (void)onService
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_SERVICE];
    JumpToWebBlk(urlStr, nil);
    
}

- (void)loginAction
{
    [self.navigationController presentViewController:makeLoginnav(nil,nil) animated:YES completion:nil];
}

- (void)onSetting
{
    BYSettingVC* vc = [[BYSettingVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)onAvatar
//{
//    BYAvatarSettingVC* vc = [[BYAvatarSettingVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//    
//}


@end
