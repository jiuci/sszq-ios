//
//  BYLoginViewController.h
//  IBY
//
//  Created by panShiyu on 14-9-9.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYNavVC.h"
#import "BYBaseVC.h"

@class BYAppDelegate;

typedef void (^BYLoginSuccessBlock)();
typedef void (^BYLoginCancelBlock)();

@interface BYLoginVC : BYBaseVC<UITextFieldDelegate>
@property (nonatomic, copy) BYLoginSuccessBlock successBlk;
@property (nonatomic, copy) BYLoginCancelBlock cancelBlk;
@property (strong, nonatomic) UITextField* userTextField;
@property (assign, nonatomic) BYAppDelegate* appDelegate;
@property (assign, nonatomic) BOOL showThirdPartyLogin;
@property (nonatomic, assign) BOOL isHomeLogin;


+ (instancetype)sharedLoginVC;
- (void)clearData;
@end

//quick creater with successBlk
BYNavVC* makeLoginnav(BYLoginSuccessBlock blk,BYLoginCancelBlock cblk);

BYNavVC* makeLoginNavFromHome(BYLoginSuccessBlock blk,BYLoginCancelBlock cblk);

