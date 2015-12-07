//
//  BYAccountEngine.m
//  IBY
//
//  Created by panshiyu on 15/6/17.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYPassportEngine.h"
#import "BYUser.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSStringExtension.h"

@implementation BYPassportEngine

+ (void)loginByUser:(NSString*)user
                pwd:(NSString*)pwd
             finish:(void (^)(BYUser* user, BYError* error))finished{
    NSString* url = SSZQAPI_USER_LGOIN;
    NSDictionary* params = @{ @"username" : user,
//                              @"epassword" : [pwd encryptstr]
                              @"password" : pwd
                              };
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if (data && !error) {
            BYUser *user = [BYUser userWithLoginDict:data];
            user.userType = @"0";
            if(user.isValid){
                finished(user,nil);
            }else{
                BYError *err = makeCustomError(BYFuErrorCannotSerialized, @"com.biyao.passport.login", @"user is not valid", nil);
                finished(nil,err);
            }
        }else if(error.code == 208103){//代表用户未注册
            BYUser *user = [[BYUser alloc] init];
            finished(user,error);
        }else{
            finished(nil,error);
        }
    }];
}
//
//- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
//{
//    _tempdata =[NSMutableData data];
//}
//- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
//{
//    [_tempdata appendData:data];
//}
//- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
//{
//}
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    NSString*str =[[NSString alloc]initWithData:_tempdata encoding:NSUTF8StringEncoding];
//}

+ (void)registByUser:(NSString*)user
                 pwd:(NSString*)pwd
            verycode:(NSString*)code
               finsh:(void (^)(BOOL success, BYError* error))finished
{
    NSString* url = SSZQAPI_USER_CUSTOMERREGISTERSERVLET;
    NSDictionary* params = @{ @"username" : user,
//                              @"epassword" : [pwd encryptstr],
                              @"password" : pwd,
                              @"verycode" : code
                              } ;
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(NO,error);
        }else{
            finished(YES,nil);
        }
    }];
}
+ (void)resetPasswordForUser:(NSString*)username
                 newPassword:(NSString*)password
             needOldPassword:(BOOL)needOldPassword
                 oldPassword:(NSString*)oldPassword
                         md5:(NSString*)md5
                      finish:(void (^)(BOOL success, BYError* error))finished;
{
    NSString* url = SSZQAPI_USER_UPDATEPASSWORD;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params safeSetValue:username forKey:@"username"];
    [params safeSetValue:[password encryptstr] forKey:@"eNewPassword"];
    if (needOldPassword) {
        [params safeSetValue:@"true" forKey:@"needOldPasswd"];
    }else{
        [params safeSetValue:@"false" forKey:@"needOldPasswd"];
    }
    [params safeSetValue:[oldPassword encryptstr] forKey:@"eOldPassword"];
    [params safeSetValue:md5 forKey:@"md5"];
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(NO,error);
        }else{
            finished(YES,nil);
        }
    }];
}
+ (void)loginWithQQaccess:(NSString*)access_token openID:(NSString *)openID finish:(void (^)(BYUser* user, BYError* error))finished;
{
    NSString* url = @"user/customer/qqlogin";
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params safeSetValue:access_token forKey:@"access_token"];
    [params safeSetValue:openID forKey:@"openid"];
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if (data && !error) {
            
            BYUser *user = [BYUser userWithLoginDict:data];
            user.userType = @"6";//TODO api中获取
            if(user.isValid){
                finished(user,nil);
            }else{
                BYError *err = makeCustomError(BYFuErrorCannotSerialized, @"com.biyao.passport.login", @"user is not valid", nil);
                finished(nil,err);
            }
        }else{
            finished(nil,error);
        }
        
    }];
}
+ (void)loginWithWXcode:(NSString*)code finish:(void (^)(BYUser* user, BYError* error))finished
{
    NSString* url = @"user/customer/wxlogin";
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params safeSetValue:code forKey:@"code"];
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
//        NSLog(@"%@,%@",error,data);
        if (data && !error) {
            
            BYUser *user = [BYUser userWithLoginDict:data];
//            NSLog(@"%@",user);
            user.userType = @"5";
            if(user.isValid){
                finished(user,nil);
            }else{
                BYError *err = makeCustomError(BYFuErrorCannotSerialized, @"com.biyao.passport.login", @"user is not valid", nil);
                finished(nil,err);
            }
        }else{
            finished(nil,error);
        }

    }];
}

@end
