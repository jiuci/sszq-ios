//
//  BYUser.m
//  IBY
//
//  Created by pan Shiyu on 14-8-26.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYUser.h"

@implementation BYUser

//数据不健全，所以这段内容未启用
- (NSDictionary*)replacedKeyFromPropertyName
{
    return @{
        @"avatar" : @"avater_url",
        @"role" : @"userrole"
    };
}

+ (instancetype)userWithLoginDict:(NSDictionary*)info {
    BYUser *user = [[BYUser alloc] init];
    user.userID = [info[@"userid"] intValue];
    user.nickname = info[@"userinfo"][@"nickname"];
    user.avatar = info[@"userinfo"][@"avater_url"];
    user.token = info[@"token"][@"token"];
    user.phoneNum = info[@"userinfo"][@"mobile"];
    user.gender = [info[@"userinfo"][@"gender"] intValue];
    user.email = info[@"userinfo"][@"email"];
    user.cardID = info[@"userinfo"][@"idcard"];
    
    return user;
}

+ (instancetype)userWithUpdateDict:(NSDictionary*)info {
    BYUser *user = [[BYUser alloc] init];
    user.userID = [info[@"userinfo"][@"customer_id"] intValue];
    user.nickname = info[@"userinfo"][@"nickname"];
    user.avatar = info[@"userinfo"][@"avater_url"];
    user.gender = [info[@"userinfo"][@"gender"] intValue];
    
    return user;
}

- (void)updateWithAnother:(BYUser*)user {
    if (!user) {
        return;
    }
    
    if (_userID != user.userID) {
        return;
    }
    
    _avatar = user.avatar;
    _phoneNum = user.phoneNum;
    _nickname = user.nickname;
    _gender = user.gender;
    _avatar = user.avatar;

}

- (BOOL)isValid
{
    if (_phoneNum && _cardID && _token && _token.length > 3) {
        return YES;
    }
    return NO;
}


@end
