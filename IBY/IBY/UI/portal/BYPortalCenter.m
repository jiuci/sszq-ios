//
//  BYPortalCenter.m
//  IBY
//
//  Created by panshiyu on 14-10-18.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYPortalCenter.h"
#import "BYAppDelegate.h"


#import "BYBaseWebVC.h"
#import "BYAlertView.h"

//#import "BYPayVC.h"
#import "BYCommonWebVC.h"
#import "BYNavVC.h"
#import "BYHomeVC.h"
#import "BYMineVC.h"

#import "BYPushWebVC.h"

@implementation BYPortalCenter

+ (instancetype)sharedPortalCenter
{
    static BYPortalCenter* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)portTo:(BYPortal)portalPage
{
    [self portTo:portalPage params:nil];
}

- (void)portTo:(BYPortal)portalPage params:(NSDictionary*)params
{
    BYNavVC* nav = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeNav;
    BYHomeVC* homeVC = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeVC;
    UIViewController* curVC = nav.currentVC;
    
    switch (portalPage) {

    case BYPortalHome:{
        
        BYHomeVC* lastVC = (BYHomeVC*)nav.rootController;
        if (params[@"noJump"]) {
            
        }else if (params[@"JumpURL"]) {
            NSURL* url = [NSURL URLWithString:params[@"JumpURL"]];
            
            if (lastVC.commonWebVC.webView) {
                [lastVC.commonWebVC.webView loadRequest:[NSURLRequest requestWithURL:url]];
            }else{
                lastVC.needJumpUrl = params[@"JumpURL"];
                return;
            }
        }else{
            NSURL* url = [NSURL URLWithString:BYURL_HOME];
            //home就不需要再跳转了
            [lastVC.commonWebVC.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
        
        if ([nav.viewControllers containsObject:[BYCommonWebVC sharedCommonWebVC]]) {
            [nav popToViewController:[BYCommonWebVC sharedCommonWebVC] animated:NO];
        }else{
            [nav pushViewController:[BYCommonWebVC sharedCommonWebVC] animated:NO];
        }
        if ([nav presentedViewController]) {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
    }break;
    case BYPortalHomeWithGlassesId:{
        if (params[@"did"]) {
            int did = [params[@"did"] intValue];
            [homeVC.commonWebVC onSelectGlasses:did];
        }
        if ([nav.viewControllers containsObject:[BYCommonWebVC sharedCommonWebVC]]) {
            [nav popToViewController:[BYCommonWebVC sharedCommonWebVC] animated:NO];
        }else{
            [nav pushViewController:[BYCommonWebVC sharedCommonWebVC] animated:NO];
        }
//        [nav popToRootViewControllerAnimated:YES];
        if ([nav presentedViewController]) {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
    }
        break;
    case BYPortalpay:{
        NSString *order_id_list = params[@"order_id_list"];
        
        if (order_id_list && curVC) {
//            BYPayVC* payvc = [[BYPayVC alloc] initWithOrderId:order_id_list];
//            [curVC.navigationController pushViewController:payvc animated:YES];
        }else{
            BYLog(@"error ,can not go to payvc");
        }
    }break;
    case BYPortalMine: {
//        BYNavVC* navVC = (BYNavVC*)tabbarVC.selectedViewController;
//        [navVC popToRootViewControllerAnimated:NO];
//        
//        if ([navVC presentedViewController]) {
//            [navVC dismissViewControllerAnimated:NO completion:nil];
//        }
//            
//        tabbarVC.selectedIndex = portalPage;
        [nav presentViewController:[BYMineVC sharedMineVC] animated:NO completion:nil];
        
    } break;
    case BYPortalBlankGoback:{
        [nav popViewControllerAnimated:NO];
        [[BYCommonWebVC sharedCommonWebVC] loadBlank];
    }break;
    default:
        break;
    }
}


- (void)portToPushUrlWithParams:(NSDictionary *)params {
    BYNavVC* nav = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeNav;
    BYHomeVC* homeVC = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeVC;
    BYPushWebVC *pushWebVC = [[BYPushWebVC alloc] init];
    pushWebVC.urlStr = params[@"JumpURL"];
    [homeVC presentViewController:pushWebVC animated:YES completion:nil];
//    [nav pushViewController:pushWebVC animated:NO];
//    [homeVC.navigationController pushViewController:pushWebVC animated:YES];
}



@end
