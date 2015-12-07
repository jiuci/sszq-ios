//
//  BYIMPassWordService.m
//  IBY
//
//  Created by forbertl on 15/10/13.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYIMService.h"
#import "BYIMEngine.h"

@implementation BYIMService
{
    NSString * _token;
    NSDate * _statusTime;
}
- (void)loadpassword:(void (^)(NSString * password, BYError* error))finished
{
    [BYIMEngine loadpassword:finished];
}


- (void)getTargetStatus:(NSString *)user finish:(void (^)(BOOL online, BYError* error))finished
{
    if (self.token) {
        BOOL shouldsend = YES;
        if (_statusTime) {
            BYLog(@"%f", [[NSDate date]timeIntervalSinceDate:_statusTime] );
            shouldsend = [[NSDate date]timeIntervalSinceDate:_statusTime] > 60;
        }
        if (!shouldsend) {
            return;
        }
        _statusTime = [NSDate date];
        [BYIMEngine getTargetStatus:user token:self.token finish:finished];
        return;
    }
    __weak typeof (self) wself = self;
    [BYIMEngine getToken:^(NSDictionary * dic,BYError* error){
        if (error) {
            BYLog(@"error%@",error);
            finished(NO,error);
        }else{
            NSString * token = dic[@"access_token"];
//            self.token = token;
            [self setToken:token inTime:dic[@"expires_in"]];
            [self getTargetStatus:user finish:finished];
        }
    }];
}

- (void)setToken:(NSString *)token inTime:(NSString *)expires
{
    _token = token;
    NSDate * expiresTime = [NSDate dateWithTimeIntervalSinceNow:[expires doubleValue]];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:token forKey:@"token"];
    [dic setObject:expiresTime forKey:@"time"];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"com.biyao.im.token"];
    
}

- (NSString*)token
{
    if (_token.length) {
        return _token;
    }
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.biyao.im.token"];
    if (dic) {
        NSDate * expiresTime = dic[@"time"];
//        NSLog(@"%@",expiresTime);
//        NSLog(@"%f",expiresTime.timeIntervalSinceNow);
//        NSLog(@"%@",dic[@"token"]);
        if (expiresTime.timeIntervalSinceNow >= 0) {
            _token = dic[@"token"];
            return _token;
        }
    }
    return nil;
}
@end
