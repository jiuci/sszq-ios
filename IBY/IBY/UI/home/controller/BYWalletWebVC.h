//
//  BYWalletWebVC.h
//  IBY
//
//  Created by chenglei on 15/11/24.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYBaseVC.h"

#import "BYMutiSwitch.h"

@interface BYWalletWebVC : BYBaseVC <UIWebViewDelegate>

@property (nonatomic, strong) BYMutiSwitch *mutiSwitch;

+ (instancetype)sharedWalletWebVC;

@end
