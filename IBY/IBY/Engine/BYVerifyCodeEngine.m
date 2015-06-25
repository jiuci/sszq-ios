//
//  BYVerifyCodeEngine.m
//  IBY
//
//  Created by panshiyu on 15/6/17.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYVerifyCodeEngine.h"
#import "Base64Helper.h"

@implementation BYVerifyCodeEngine
+ (void)fetchImageVerifyCode:(void (^)(UIImage*, BYError*))finished
{
    NSString* url = @"vcode/getvcode";
    NSDictionary* param = @{ @"id" : [BYAppCenter sharedAppCenter].uuid };
    
    [BYNetwork get:url params:param finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(nil,error);
        }else{
            NSString *stringData = data[@"decodeImage"];
            UIImage *codeImage = nil;
            if (stringData) {
                codeImage = [Base64Helper  string2Image:stringData];
            }
            if (codeImage) {
                finished(codeImage,nil);
            }else{
                BYError *err = makeCustomError(BYFuErrorCannotSerialized, @"com.biyao.verifycode.image", @"image is not valid", nil);
                finished(nil,err);
            }
        }
    }];
}
+ (void)checkImageVerifyCode:(NSString*)code finish:(void (^)(BOOL success, BYError* error))finished;
{
    NSString* url = @"vcode/validatevcode";
    NSDictionary* param = @{
                            @"captcha_input" : code,
                            @"id" : [BYAppCenter sharedAppCenter].uuid
                            };
    [BYNetwork get:url params:param finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(NO,error);
        }else{
            finished(YES,nil);
        }
    }];
}
+ (void)checkVerifyCode:(NSString*)code phone:(NSString*)phone finish:(void (^)(NSString* md5, BYError* error))finished
{
    NSString* url = @"regist/checkPhoneAndCode";
    NSDictionary* params = @{ @"mobile" : phone,
                              @"code" : code };
    
    [BYNetwork get:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(nil,error);
        }else{
            NSString* md5 = data[@"md5"];
            if (md5.length > 30) {
                finished(data[@"md5"],nil);
            }else{
                BYError*err = [BYError errorWithDomain:@"com.biyao.VerifyCode.checkVerifycode" code:BYNetErrorDomainWrongFormat userInfo:nil];
                finished(nil,err);
            }
        }
    }];
}
+ (void)fetchSMSVerifyCodeForRegistWithPhone:(NSString*)phoneNum finish:(void (^)(BYFetchVerifyCodeStatus status, BYError* error))finished;
{
    NSString* url = @"user/customer/MobilePreRegist";
    NSDictionary* param = @{ @"Mobile" : phoneNum };
    
    [BYNetwork post:url params:param finish:^(NSDictionary* data, BYError* error) {
        NSLog(@"%@,%@",data,error);
        if(error){
            if (error.code == 208101) {
                finished(BYFetchCodeRegisted,error);
            }else{
                finished(BYFetchCodeFail,error);
            }
        }else{
            finished(BYFetchCodeSuccess,nil);
        }
    }];
}
+ (void)fetchSMSVerifyCodeForResetPasswordWithPhone:(NSString*)phoneNum finish:(void (^)(BYFetchVerifyCodeStatus status, BYError* error))finished;
{
    NSString* url = @"user/customer/CustomerAcquireCode";
    NSDictionary* param = @{ @"Mobile" : phoneNum };
    
    [BYNetwork post:url params:param finish:^(NSDictionary* data, BYError* error) {
        if(error){
            if (error.code == 208101 && 0) {//TODO API不完整，不知道未注册的时候返回什么错误码
                finished(BYFetchCodeNeedRegist,error);
            }else{
                finished(BYFetchCodeFail,error);
            }
        }else{
            finished(BYFetchCodeSuccess,nil);
        }
    }];
}
@end
