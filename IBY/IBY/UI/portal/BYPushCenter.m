//
//  BYPushCenter.m
//  IBY
//
//  Created by panshiyu on 15/2/15.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYPushCenter.h"
#import "BYPushUnit.h"

@implementation BYPushCenter

+ (instancetype)sharedPushCenter
{
    static BYPushCenter* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)handleRemoteInfoWithApplication:(UIApplication*)application userinfo:(NSDictionary*)userInfo
{
    BYPushUnit* unit = [BYPushUnit unitWithRemoteInfo:userInfo];
    if (!unit) {
        return;
    }

    int isActive = 0;
    //所有的数据监测在pushCenter内部就做完，让portal可以放心大胆的用
    if (application.applicationState == UIApplicationStateInactive) {
        isActive = 0;
        //opened from a push notification when the app was on background
        switch (unit.type) {
        case BYPushTypeDesignDetail: {  // 1
            if (unit.pushParams[@"did"]) {
                NSString* designDetailUrl = [NSString stringWithFormat:@"%@%d",BYURL_M_DetailDesign,[unit.pushParams[@"did"] intValue]];
                [BYAppCenter sharedAppCenter].pushId = unit.pushId;
                NSDictionary* params = @{@"JumpURL":designDetailUrl};
                [[BYPortalCenter sharedPortalCenter] portTo:BYPortalHome params:params];
                [iConsole log:@"design %@",params];
//                [[BYPortalCenter sharedPortalCenter] portTo:BYPortalDesignDetail params:unit.pushParams];
            }
        } break;
        case BYPushTypeMWeb: {  // 2
            if (unit.pushParams[@"url"] && [unit.pushParams[@"url"] hasPrefix:@"http://"]) {
                [BYAppCenter sharedAppCenter].pushId = unit.pushId;
                NSDictionary* params = @{@"JumpURL":unit.pushParams[@"url"]};
                [iConsole log:@"url %@",params];
//                [[BYPortalCenter sharedPortalCenter] portTo:BYPortalHome params:params];
                // pushUrl跳转
                [[BYPortalCenter sharedPortalCenter] portToPushUrlWithParams:params];
            }
        } break;
        default:
                [iConsole log:@"none %@",userInfo];
            break;
        }
    }
    else if (application.applicationState == UIApplicationStateActive) {
        isActive = 1;
        // a push notification when the app is running. So that you can display an alert and push in any view
        if (unit.message) {
            alertPushSimplely(unit.message);
        }
    }
    [[BYAppCenter sharedAppCenter] receivedPushInActive:isActive];
}

@end
