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

#import "BYCaptureVC.h"
#import "BYGlassPageVC.h"

#import "BYBarButtonItem.h"
#import "BYCommonWebVC.h"

#import "BYAvatarSettingVC.h"
//#import "BYtest.h"

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


    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"个人中心";
    [self.mutiSwitch setSelectedAtIndex:2];
    BOOL isLogin = checkLoginCookies();
    if (!isLogin) {
        [[BYAppCenter sharedAppCenter] logout];
    }
    addCookies(BYURL_MINE, @"gobackuri", @".biyao.com");
    //    addCookies(BYURL_MINE, @"gobackuri", @"m.biyao.com");
    
    
    [self updateUI];
    [self updateData];
}
- (void)viewWillDisappear:(BOOL)animated
{
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
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithImgName:@"btn_meassages" highImgName:@"btn_meassages" handler:^(id sender) {
        if (![BYAppCenter sharedAppCenter].isLogin) {
            [self loginAction];
            return;
        }
        JumpToWebBlk(@"http://m.biyao.com/message", nil);
    }];
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

    [self appendCell:@"icon_usercenter_orderinquiry"
               title:@"我的订单"
                 top:12
                 sel:@selector(onOrders)];

    [self appendCell:@"icon_usercenter_coupon"
               title:@"我的红包"
                 top:0
                 sel:@selector(onMycoupon)];
    
    [self appendCell:@"icon_usercenter_mydesign"
               title:@"我的作品集"
                 top:0
                 sel:@selector(onMydesign)];

    [self appendCell:@"icon_usercenter_address"
               title:@"我的地址"
                 top:0
                 sel:@selector(onAdress)];
    
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
    
    
//    [self appendCell:@"icon_usercenter_setting"
//               title:@"相机"
//                 top:12
//                 sel:@selector(onCamera)];
//    
//    [self appendCell:@"icon_usercenter_setting"
//               title:@"pageView"
//                 top:12
//                 sel:@selector(pageScroll)];
    
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
        
        UIButton* btn1 = [BYBarButton barBtnWithIcon:@"icon_home" hlIcon:@"icon_home" title:@"首页"];
        [_mutiSwitch addButtonWithBtn:btn1
                               handle:^(id sender) {
                                   [wself.navigationController popToRootViewControllerAnimated:NO];
                               }];
        
        UIButton* btn2 = [BYBarButton barBtnWithIcon:@"icon_cart" hlIcon:@"icon_cart" title:@"购物车"];
        [_mutiSwitch addButtonWithBtn:btn2
                               handle:^(id sender) {
                                   JumpToWebBlk(BYURL_CARTLIST, nil);
                               }];
        
        UIButton* btn3 = [BYBarButton barBtnWithIcon:@"icon_mine_highlight" hlIcon:@"icon_mine_highlight" title:@"我的必要"];
        [_mutiSwitch addButtonWithBtn:btn3
                               handle:^(id sender) {
                                   //再进我的必要就不响应了
                                   [wself.mutiSwitch setSelectedAtIndex:2];
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

- (void)pageScroll{
//    
//    BYtest* test = [[BYtest alloc] init];
//    [test detectEyes];
}

- (void)onCamera
{
    
    
    NSString* glassCache = @"glassCache";
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:glassCache];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if(array.count == 0){
        BYCaptureVC* capVC = [[BYCaptureVC alloc] init];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:capVC];
        [self presentViewController:nav animated:YES completion:^{
        }];
    }else{
        BYGlassPageVC* pageVC = [[BYGlassPageVC alloc]init];
        [self.navigationController pushViewController:pageVC animated:YES];
    }
}

- (void)onMycoupon
{

    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
    JumpToWebBlk(@"http://m.biyao.com/money/money", nil);
}


- (void)onMydesign
{
    
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
    JumpToWebBlk(@"http://m.biyao.com/account/myworks", nil);
}

- (void)onAdress
{
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
    BYAddressManagelistVC *vc = [[BYAddressManagelistVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)onOrders
{
   
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
    JumpToWebBlk(@"http://m.biyao.com/order/orderlist", nil);
}

- (void)onToPayOrders
{

    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
//    if ([BYAppCenter sharedAppCenter].user.notPayOrderNum == 0) {
//        [MBProgressHUD topShowTmpMessage:@"您还没有待付款订单"];
//        return;
//    }
    JumpToWebBlk(@"http://m.biyao.com/order/orderlist?orderStatus=1", nil);

    
}

- (void)onInProcessOrders
{


    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
    JumpToWebBlk(@"http://m.biyao.com/order/orderlist?orderStatus=3", nil);
}

- (void)onInRefundOrders
{
    
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
//    if ([BYAppCenter sharedAppCenter].user.refundNum == 0) {
//        [MBProgressHUD topShowTmpMessage:@"您还没有退款/售后订单"];
//        return;
//    }
    
    JumpToWebBlk(@"http://m.biyao.com/refund/myrefund", nil);
}

- (void)onToDeliverConfirmOrders
{
    
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
//    if ([BYAppCenter sharedAppCenter].user.toReceiveOrderNum == 0) {
//        [MBProgressHUD topShowTmpMessage:@"您还没有待收货订单"];
//        return;
//    }
    JumpToWebBlk(@"http://m.biyao.com/order/orderlist?orderStatus=4", nil);
}

- (void)onService
{
    JumpToWebBlk(@"http://m.biyao.com/service", nil);
    
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
