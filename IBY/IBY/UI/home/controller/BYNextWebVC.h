//
//  BYNextWebVC.h
//  IBY
//
//  Created by chenglei on 15/12/4.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYBaseVC.h"

@interface BYNextWebVC : BYBaseVC <UIWebViewDelegate>

/**
 *  true:从home/wallet/rank VC界面push跳转进来， false:从JPushNoti远程通知跳转
 */
@property (nonatomic, assign) BOOL isJumpFromTapAction;

/**
 *  true:隐藏navBar 即navigationBarHidden = true (客服中心页暂用)
 */
@property (nonatomic, assign) BOOL isHiddenNavBar;

@property (nonatomic, copy) NSString *urlStr;


@end
