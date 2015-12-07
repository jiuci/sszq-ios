//
//  BYAppInfo.m
//  IBY
//
//  Created by panshiyu on 14-10-27.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYAppService.h"
#import "MJExtension.h"

@implementation BYAppService

- (void)checkAppNeedUpdate:(void (^)(BYVersionInfo* versionInfo, BYError* error))finished
{
    NSString* url = @"app/checkapp";
    [BYNetwork get:url params:nil finish:^(NSDictionary* data, BYError* error) {
        if (error) {
            finished(nil,error);
            return ;
        }
        BYVersionInfo *versionInfo = [BYVersionInfo objectWithKeyValues:data[@"AppUpdate"]];
        finished(versionInfo,nil);
    }];
}

- (void)uploadToken:(NSString*)token finished:(void (^)(BOOL success, BYError* error))finished
{
    NSString* url = @"/apppush/token/put";
    NSDictionary* params = @{
                             @"pushtoken" : token,
                             @"enable" : @(1)
                             };
//    NSString* url = SSZQAPI_PUSH_REFRESHTOKEN;
//    NSDictionary* params = @{
//                             @"pushtoken" : token,
//                             @"enable" : @(1)
//                             };
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if (error) {
            finished(NO,error);
            return ;
        }
        finished(YES,nil);
    }];
}

- (void)receivedPushInActive:(int)isactive finished:(void (^)(BOOL success, BYError* error))finished
{
    NSString* url = @"/apppush/pushid/put";
    NSDictionary* params = @{
                             @"isactive" : @(isactive),
                             @"enable" : @(1)
                             };
    
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if (error) {
            finished(NO,error);
            return ;
        }
        finished(YES,nil);
    }];
}

@end

@implementation BYVersionInfo

- (NSDictionary*)replacedKeyFromPropertyName
{
    return @{
        @"url" : @"url",
        @"name" : @"appName",
        @"version" : @"appVersion",
        @"forceUpdate" : @"needForceUpdate",
        @"hasNewVersion" : @"hasNewVersion",
        @"info" : @"versionInfo"
    };
}

@end
