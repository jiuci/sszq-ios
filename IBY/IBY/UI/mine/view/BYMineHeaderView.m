 //
//  BYHeaderView.m
//  IBY
//
//  Created by coco on 14-9-18.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYMineHeaderView.h"
#import "BYUser.h"
//#import "BYOrderlistVC.h"
//#import "BYSetNicknameVC.h"
#import "BYLoginVC.h"
#import "BYRegist1VC.h"
#import "BYImageView.h"
#import "BYMineVC.h"
#import "BYUserProfileVC.h"
#import "BYNumberTip.h"


@interface BYMineHeaderView ()
{
    BYNumberTip * notPayOrderTip;
    BYNumberTip * toReceiveOrderTip;
    BYNumberTip * refundOrderTip;
}
@property (weak, nonatomic) IBOutlet BYImageView* userIcon;
//@property (weak, nonatomic) IBOutlet UILabel* userName;   // xib
@property (nonatomic, strong) UILabel* userName;
@property (nonatomic, strong) UIImageView *genderImgView;
@property (weak, nonatomic) IBOutlet UIView* loginView;
@property (weak, nonatomic) IBOutlet UIView* orderStatusView;

@property (nonatomic, strong) UIButton* loginButton;
@property (nonatomic, strong) UIButton* registButton;
@property (nonatomic, strong) UIButton* notPayOrderBtn;
@property (nonatomic, strong) UIButton* refundOrderBtn;
@property (nonatomic, strong) UIButton* notReceivedOrderBtn;
@end


static CGFloat nameFontSize = 16;


@implementation BYMineHeaderView
+ (instancetype)headerView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"BYMineHeaderView" owner:nil options:nil] lastObject];
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 180);
//}

- (void)setupUI
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 150);
    
    [_userIcon addTapAction:@selector(onUserInfo) target:self];

    _userName = [[UILabel alloc] initWithFrame:CGRectZero];
    _userName.backgroundColor = [UIColor clearColor];
    _userName.font = [UIFont systemFontOfSize:nameFontSize];
    _userName.textAlignment = NSTextAlignmentCenter;
    _userName.textColor = [UIColor whiteColor];
    [_userName addTapAction:@selector(onUserInfo) target:self];
    _userName.shadowColor = HEXACOLOR(0x000000, .2);
    _userName.shadowOffset = CGSizeMake(0, 1.0);
    [self addSubview:_userName];

    
    _genderImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_genderImgView addTapAction:@selector(onUserInfo) target:self];
    [self addSubview:_genderImgView];
    
    
    //setup  登录项
    UIImageView* bgImagview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _loginView.width, _loginView.height)];
    UIImage* bgImage = [UIImage imageNamed:@"bg_usercenter_header"];
    bgImagview.image = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width / 2 topCapHeight:0.];
//    [_loginView addSubview:bgImagview];
    _mineVC = [BYMineVC sharedMineVC];
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 25)];
    [_loginButton setTitle:@"登录 / 注册" forState:UIControlStateNormal];
    [_loginButton setTitleColor:BYColorb768 forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_loginButton addTarget:_mineVC action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.backgroundColor = [UIColor clearColor];
    [_loginButton setBackgroundImage:[[UIImage imageNamed:@"bg_usercenter_trans_login"] resizableImage] forState:UIControlStateNormal];
    _loginView.backgroundColor = [UIColor clearColor];
    [_loginView addSubview:_loginButton];
    
    
    
    

//    UIImageView* loginSepLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 15)];
//    loginSepLineView.left = _loginButton.right;
//    loginSepLineView.center = CGPointMake(_loginView.width / 2, _loginView.height / 2);
//    loginSepLineView.image = [UIImage imageNamed:@"line_usercenter_login"];
//    [_loginView addSubview:loginSepLineView];
//
//    _registButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, _loginView.height)];
//    [_registButton setTitle:@"注册" forState:UIControlStateNormal];
//    _registButton.titleLabel.font = [UIFont systemFontOfSize:11];
//    [_registButton setTitleColor:BYColorb768 forState:UIControlStateNormal];
//    _registButton.left = loginSepLineView.right;
//    [_registButton addTarget:self action:@selector(registAction) forControlEvents:UIControlEventTouchUpInside];
//    [_loginView addSubview:_registButton];

    //setup 订单项目
    CGFloat btnWidth = (SCREEN_WIDTH - 1) / 2;
    CGFloat btnHeight = 44;
    
    
    //
//    _notPayOrderBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight) icon:@"icon_usercenter_orderpayment" iconEdge:UIEdgeInsetsMake(0, 0, 0, 10) bgIcon:nil title:@"待付款"];
//    CGSize size = [_notPayOrderBtn.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName, nil]];
////    [_notPayOrderBtn setTitleEdgeInsets:UIEdgeInsetsMake( 0,-[_notPayOrderBtn imageForState:UIControlStateNormal].size.width, -26,0)];
////    [_notPayOrderBtn setImageEdgeInsets:UIEdgeInsetsMake(-18, 0,0, -size.width)];
//    _notPayOrderBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    [_notPayOrderBtn setTitleColor:BYColorWhite forState:UIControlStateNormal];
//    _notPayOrderBtn.left = 0;
//    [_notPayOrderBtn addTarget:_mineVC action:@selector(onToPayOrders) forControlEvents:UIControlEventTouchUpInside];
//    [_orderStatusView addSubview:_notPayOrderBtn];
//    notPayOrderTip = [BYNumberTip numberTipwithFrame:CGRectMake(20, 0, 8, 8) inView:_notPayOrderBtn];
//    
//
//    UIImageView* orderSepLineView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, btnHeight - 15)];
//    orderSepLineView1.image = [UIImage imageNamed:@"line_usercenter_separate"];
//    orderSepLineView1.left = _notPayOrderBtn.right;
//    orderSepLineView1.centerY = _orderStatusView.height / 2;
//    [_orderStatusView addSubview:orderSepLineView1];

    
    
    //
//    _notReceivedOrderBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight) icon:@"icon_usercenter_receive" iconEdge:UIEdgeInsetsMake(0, 0, 0, 10) bgIcon:nil title:@"待收货"];
//    size = [_notReceivedOrderBtn.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName, nil]];
//    [_notReceivedOrderBtn setTitleEdgeInsets:UIEdgeInsetsMake( 0,-[_notReceivedOrderBtn imageForState:UIControlStateNormal].size.width, -26,0)];
//    [_notReceivedOrderBtn setImageEdgeInsets:UIEdgeInsetsMake(-18, 0,0, -size.width)];
//    _notReceivedOrderBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    [_notReceivedOrderBtn setTitleColor:BYColorWhite forState:UIControlStateNormal];
//    _notReceivedOrderBtn.left = orderSepLineView1.right;
//    [_notReceivedOrderBtn addTarget:_mineVC action:@selector(onToDeliverConfirmOrders) forControlEvents:UIControlEventTouchUpInside];
//    [_orderStatusView addSubview:_notReceivedOrderBtn];
    
//    toReceiveOrderTip = [BYNumberTip numberTipwithFrame:CGRectMake(20, 0, 8, 8) inView:_notReceivedOrderBtn];

//    UIImageView* orderSepLineView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 32)];
//    orderSepLineView2.image = [UIImage imageNamed:@"line_usercenter_separate"];
//    orderSepLineView2.left = _notReceivedOrderBtn.right;
//    orderSepLineView2.centerY = _orderStatusView.height / 2;
//    [_orderStatusView addSubview:orderSepLineView2];

    
    
//    _refundOrderBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight) icon:@"icon_usercenter_refund" iconEdge:UIEdgeInsetsMake(0, 0, 0, 10) bgIcon:nil title:@"退款/售后"];
////    NSLog(@"%@",[UIImage imageNamed:@"icon_usercenter_refund"]);
//    size = [_refundOrderBtn.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName, nil]];
////    [_refundOrderBtn setTitleEdgeInsets:UIEdgeInsetsMake( 0,-[_refundOrderBtn imageForState:UIControlStateNormal].size.width, -26,0)];
////    [_refundOrderBtn setImageEdgeInsets:UIEdgeInsetsMake(-18, 0,0, -size.width)];
//    _refundOrderBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    [_refundOrderBtn setTitleColor:BYColorWhite forState:UIControlStateNormal];
//    _refundOrderBtn.left = orderSepLineView1.right;
//    [_refundOrderBtn addTarget:_mineVC action:@selector(onInRefundOrders) forControlEvents:UIControlEventTouchUpInside];
//    [_orderStatusView addSubview:_refundOrderBtn];
//    refundOrderTip = [BYNumberTip numberTipwithFrame:CGRectMake(20, 0, 8, 8) inView:_refundOrderBtn];
//
    
}



- (void)updateUI
{
    

    if ([BYAppCenter sharedAppCenter].isLogin) {
        
        [self.userIcon setImageWithUrl:[BYAppCenter sharedAppCenter].user.avatar placeholderName:@"icon_user_default"];
        [_userIcon.layer setCornerRadius:_userIcon.width / 2];
        CALayer* imageLayer = _userIcon.layer;
        [imageLayer setMasksToBounds:YES];

        self.userName.userInteractionEnabled = YES;
        self.userName.text = [BYAppCenter sharedAppCenter].user.nickname;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFontSize],};
        CGSize textSize = [self.userName.text boundingRectWithSize:CGSizeMake(200, nameFontSize) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        
        CGFloat userNameW = textSize.width + 10;
        CGFloat userNameH = textSize.height;
        CGFloat genderImgW = 16;
        CGFloat userNameX = (SCREEN_WIDTH - userNameW - genderImgW) / 2;
        [_userName setFrame:CGRectMake(userNameX, _userIcon.bottom + 16, userNameW, userNameH)];
        
        switch ([BYAppCenter sharedAppCenter].user.gender) {
            case 0: {
                _genderImgView.image = [UIImage imageNamed:@"icon_usercenter_male"];
                _genderImgView.frame = CGRectMake(_userName.right, _userName.top, genderImgW, genderImgW);
                _genderImgView.centerY = _userName.centerY;
            }
                break;
            case 1: {
                _genderImgView.image = [UIImage imageNamed:@"icon_usercenter_female"];
                _genderImgView.frame = CGRectMake(_userName.right, _userName.top, genderImgW, genderImgW);
                _genderImgView.centerY = _userName.centerY;
                break;
            }
            default: {
                _genderImgView.image = nil;
                _userName.centerX = _userIcon.centerX;
                break;
            }
        }

        _loginView.hidden = YES;
        
        refundOrderTip.number = [BYAppCenter sharedAppCenter].user.refundNum;
        toReceiveOrderTip.number = [BYAppCenter sharedAppCenter].user.toReceiveOrderNum;
        notPayOrderTip.number = [BYAppCenter sharedAppCenter].user.notPayOrderNum;
    }
    else {
        self.userName.userInteractionEnabled = NO;
        self.userIcon.image = [UIImage imageNamed:@"icon_user_default"];
        self.userName.text = nil;

        _loginView.hidden = NO;
        _loginView.centerX = SCREEN_WIDTH / 2;
    }
    
}

- (void)onUserInfo
{
    if ([BYAppCenter sharedAppCenter].isLogin) {
        BYUserProfileVC* userProfileVC = [[BYUserProfileVC alloc] init];
        [_mineVC.navigationController pushViewController:userProfileVC animated:YES];
    }else{
        [_mineVC loginAction];
    }
    
}


@end
