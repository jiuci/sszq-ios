//
//  BYUserEngine.m
//  IBY
//
//  Created by panshiyu on 15/6/17.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYUserEngine.h"
#import "BYUser.h"
#import "BYAppCenter.h"

@implementation BYUserEngine

+ (void)refreshUserToken:(void (^)(BOOL isSuccess, BYError* error))finished
{
    NSString* url = SSZQAPI_PUSH_REFRESHTOKEN;
    [BYNetwork post:url params:nil finish:^(NSDictionary* data, BYError* error) {
        if (error) {
            finished(NO,error);
        }else{
            finished(YES,nil);
        }
    }];
}

+ (void)fetchUserLatestStatus:(void (^)(BOOL success, BYError* error))finished
{
    if (![BYAppCenter sharedAppCenter].user.userID) {
        BYError *err = makeCustomError(BYFuErrorInvalidParameter, @"com.biyao.user.update",@"userID is empty", nil);
        finished(NO,err);
        return;
    }
    
#warning SSZQ-TEST----------------NEEDDO
    // 后台接口暂时未调好，先不做网络请求
    return;
    
    NSString* url = @"/user/customer/GetUserInformation";
    NSDictionary* params = @{
                             @"uid" : @([BYAppCenter sharedAppCenter].user.userID)
                             };
    
    [BYNetwork get:url params:params finish:^(NSDictionary* data, BYError* error) {
        if (data && !error) {
            BYUser *user = [BYUser userWithUpdateDict:data];
            [[BYAppCenter sharedAppCenter].user updateWithAnother:user];
            if(user){
                finished(YES,nil);
            }else{
                BYError *err = makeCustomError(BYFuErrorCannotSerialized, @"com.biyao.user.update", @"user serialized fail ", nil);
                finished(NO,err);
            }
        }else {
            finished(NO,error);
        }
    }];
}

+ (void)checkIfNicknameValid:(NSString*)nickname finish:(void (^)(BOOL isExist, BYError* error))finished
{
    NSString* url = @"customermessage/checkNickName";
    
    NSDictionary* params = @{ @"nickname" : nickname ,
                              @"mobile":[BYAppCenter sharedAppCenter].user.phoneNum};
    
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(YES,error);
        }else{
            finished(NO,nil);
        }
    }];
}


#import "BYNetwork.h"
+ (void)syncUserDataAfterLogin:(void (^)(BOOL isSuccess, BYError* error))finished {
    if (![BYAppCenter sharedAppCenter].isLogin) {
        BYError *err = makeCustomError(BYFuErrorCannotRunAPI, @"com.biyao.user.sync", @"can not sync with no logining in", nil);
        finished(NO,err);
        return;
    }
  
    NSString* url = @"/shopCar/updateCustomerId";
    NSDictionary* params = @{
                             @"uid" : @([BYAppCenter sharedAppCenter].user.userID)
                             };
   
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if (error) {
            finished(NO,error);
        }else{
            finished(YES,nil);
        }
    }];
//    NSLog(@"%@",[BYNetwork sharedNetwork]);
}
+ (void)updateNickname:(NSString*)nickname finish:(void (^)(BOOL isSuccess, BYError* error))finished
{
    NSString* url = @"user/customer/UpdateInformation";
    
    NSDictionary* params = @{ @"nickname" : nickname,
                              @"gender" : [NSString stringWithFormat:@"%d", [BYAppCenter sharedAppCenter].user.gender] };
    
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(NO,error);
        }else{
            [BYAppCenter sharedAppCenter].user.nickname = nickname;
            finished(YES,nil);
        }
    }];
}

+ (void)updateGender:(NSString*)gender finish:(void (^)(BOOL success, BYError* error))finished
{
    NSString* url = @"user/customer/UpdateInformation";
    
    NSDictionary* params = @{ @"nickname" : [BYAppCenter sharedAppCenter].user.nickname,
                              @"gender" : gender };
    
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(NO,error);
        }else{
            [BYAppCenter sharedAppCenter].user.gender = [gender intValue];
            finished(YES,nil);
        }
    }];
    
}
@end
