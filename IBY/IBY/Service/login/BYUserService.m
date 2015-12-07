//
//  BYLoginService.m
//  IBY
//
//  Created by pan Shiyu on 14-8-26.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYUserService.h"
#import "BYUser.h"
#import "BYAppCenter.h"
#import "BYUserEngine.h"
#import "BYCartService.h"

BYError* makeUsrError()
{
    return [BYError errorWithDomain:@"登录名或者密码错误" code:222 userInfo:nil];
}

@implementation BYUserService



- (void)refreshToken:(void (^)(BOOL isSuccess, BYError* error))finished
{
    NSString* url = SSZQAPI_PUSH_REFRESHTOKEN;
    [BYNetwork post:url params:nil finish:^(NSDictionary* data, BYError* error) {
        if (data && !error) {
            //成功
            finished(YES,nil);
        }else {
            finished(NO,nil);
        }
    }];
    
}

- (void)fetchUserLatestStatus:(void (^)(BOOL isSuccess, BYError* error))finished
{
    [BYUserEngine fetchUserLatestStatus:finished];

}

//- (void)checkNicknameByName:(NSString*)nickname finish:(void (^)(BOOL))finished
//{
//    NSString* url = @"customermessage/checkNickName";
//
//    NSDictionary* params = @{ @"nickname" : nickname ,
//                              @"mobile":[BYAppCenter sharedAppCenter].user.phoneNum};
//
//    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
//        if(error){
//            finished(TRUE);
//            return ;
//        }
//        finished(FALSE);
//    }];
//}

- (void)updateNicknameByName:(NSString*)nickname finish:(void (^)(BOOL success, BYError* error))finished
{

    [BYUserEngine updateNickname:nickname finish:finished];
}

- (void)updateGender:(NSString*)gender finish:(void (^)(BOOL success, BYError* error))finished;
{
    NSString * updateGender = @"0";
    if ([gender isEqualToString:@"男"]) {
        updateGender = @"0";
    }
    if ([gender isEqualToString:@"女"]) {
        updateGender = @"1";
    }
    if ([gender isEqualToString:@"保密"]) {
        updateGender = @"-1";
    }
    [BYUserEngine updateGender:updateGender finish:finished];
}
@end
