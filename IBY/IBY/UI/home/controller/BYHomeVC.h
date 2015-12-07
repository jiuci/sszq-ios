//
//  BYHomeVC.h
//  IBY
//
//  Created by panShiyu on 14-9-10.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYBaseVC.h"
#import "BYCommonWebVC.h"
#import "BYMutiSwitch.h"


@interface BYHomeVC : BYBaseVC  <UIWebViewDelegate>

@property (nonatomic, assign) BYCommonWebVC * commonWebVC;
@property (nonatomic, strong) BYMutiSwitch *mutiSwitch;
@property (nonatomic, strong) NSString * needJumpUrl;

@property (nonatomic, assign) BOOL isNeedJumpVC;

- (void)reloadData;
- (void)onCelltap:(NSString*)link;

@end
