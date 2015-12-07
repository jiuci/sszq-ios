//
//  BYTools.m
//  IBY
//
//  Created by panShiyu on 14/12/4.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYTools.h"

@implementation BYTools

@end

void clearCookies()
{
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    for (NSHTTPCookie* obj in cookies) {
        [cookieJar deleteCookie:obj];
    }
}

void inputCookies()
{
    setCookies(@"DZVISIT", [BYAppCenter sharedAppCenter].visitCode);
    setCookies(@"fromapp", @"ios|21");
    setCookies(@"uuid", [BYAppCenter sharedAppCenter].uuid);
    setCookies(@"platform", @"iOS");
    setCookies(@"__appversion", @"21");
    setCookies(@"source", @"biyao");
    setCookies(@"__osv", [BYAppCenter sharedAppCenter].systemVersion);

    if (![BYAppCenter sharedAppCenter].isLogin) {
        resetCookies();
        return;
    }

    NSString* strUid = IntToString([BYAppCenter sharedAppCenter].user.userID);
    NSString* token = [BYAppCenter sharedAppCenter].user.token;
    NSString* idcard = [BYAppCenter sharedAppCenter].user.idCard;
//    token = [token URLEncodedString];
    token = [token URLEncodedStringForMweb];
    //userinfo 规则: 昵称,头像地址,uid ,手机号    写入Cookie前需要做URLEncoder

    NSString* uinfoStr = [NSString stringWithFormat:@"%@", [[BYAppCenter sharedAppCenter].user cookieUserInfoStr]];
    NSString* userinfo = [uinfoStr URLEncodedStringForMweb];
    
    setCookies(@"uid", strUid);
    setCookies(@"token", token);
    setCookies(@"userinfo", userinfo);
    setCookies(@"idcard", idcard);
//    logCookies();
    
//    NSString *domain = @".biyao.com";
//    setCookies(@"Domain", domain);
}

BOOL checkLoginCookies()
{
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    NSMutableArray * cookiesNames = [NSMutableArray array];
    for (NSHTTPCookie* obj in cookies) {
        if ([obj.domain isEqualToString:@".biyao.com"]) {
            [cookiesNames addObject:obj.name];
        }
    }
    return [cookiesNames containsObject:@"uid"]&&[cookiesNames containsObject:@"token"]&&[cookiesNames containsObject:@"userinfo"]&&[cookiesNames containsObject:@"idcard"];
}

NSHTTPCookie* createCookie(NSString* name, NSString* value)
{
    NSMutableDictionary* cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];

    [cookieProperties setObject:@".biyao.com" forKey:NSHTTPCookieDomain];
//    [cookieProperties setObject:@"192.168.97.69" forKey:NSHTTPCookieDomain];
//    [cookieProperties setObject:@"192.168.97.135" forKey:NSHTTPCookieDomain];

    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:3600 *24 *14] forKey:NSHTTPCookieExpires];

    NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    return cookie;
}

void setCookies(NSString* name, NSString* value)
{
    if (name && value) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:createCookie(name, value)];
    }
}

void resetCookies()
{
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    for (NSHTTPCookie* obj in cookies) {
        if (![obj.name isEqual:@"DZVISIT"]
            && ![obj.name isEqual:@"fromapp"]
            && ![obj.name isEqual:@"uuid"]
            && ![obj.name isEqual:@"gobackuri"]
            && ![obj.name isEqual:@"userinfo"]) {
            [cookieJar deleteCookie:obj];
        }
    }
}

void addCookies(NSString* uriStr,NSString* inCookieName, NSString* inCookieDomain)
{
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    NSString * objvalue = @"/index~";
//    for (NSHTTPCookie* obj in cookies) {
//        if ([obj.name isEqualToString:inCookieName]&&[obj.domain isEqualToString:inCookieDomain]) {
//            objvalue = [obj.value URLDecodedString];
//         
//        }
//    }
    NSString* value = [NSString stringWithFormat:@"%@~%@",objvalue,uriStr];

//    if (![objvalue hasSuffix:uriStr]||1) {
//        value = [NSString stringWithFormat:@"%@~%@",objvalue,uriStr];
//    }else{
//        value = objvalue;
//    }
    
//    NSLog(@"adding - %@",value);
    value = [value URLEncodedStringForMweb];
    
    if ([uriStr isEqualToString:@""]) {
        value = @"";
    }
    NSMutableDictionary* cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:inCookieName forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    
    [cookieProperties setObject:inCookieDomain forKey:NSHTTPCookieDomain];
    
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@(0) forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:3600 *24 *14] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
  
}

NSString * loadCookies(NSString* inCookieName, NSString* inCookieDomain)
{
    NSString * value;
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    for (NSHTTPCookie* obj in cookies) {
        if ([obj.name isEqualToString:inCookieName]&&[obj.domain isEqualToString:inCookieDomain]) {
            value = [obj.value URLDecodedString];
            
        }
    }
    return value;
}

void loggobackCookies()
{
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    NSString * objvalue = @"/index~http://m.biyao.com/index";
    for (NSHTTPCookie* obj in cookies) {
        if ([obj.name isEqualToString:@"gobackuri"]) {
            objvalue = [obj.value URLDecodedString];
            BYLog(@"gobackuri - %@ - %@",objvalue,obj.domain);
        }
    }

    
}

void logCookies()
{
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    for (NSHTTPCookie* obj in cookies) {
//        NSLog(@"%@ - %@", obj.name, obj.value);
        BYLog(@"%@ - %@ - %@ - %@", obj.name, obj.value, obj.domain, obj.path);
    }
}

UIImageView* makeSepline()
{
    UIImageView* line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_common"]];
    [line setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    return line;
}

UIImageView* makeImgView(CGRect frame, NSString* picName)
{
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [[UIImage imageNamed:picName] resizableImage];
    return imgView;
}

void alertError(NSError* error)
{
    NSString* str = BYMSG_POOR_NETWORK;
    if (error && (error.userInfo[@"msg"] || error.userInfo[@"message"])) {
        str = error.userInfo[@"msg"] ? error.userInfo[@"msg"] : error.userInfo[@"message"];
    }

    [MBProgressHUD topShowTmpMessage:str];
}

void alertCommonError(NSError* error, NSString* defaultMessage)
{
    NSString* str = defaultMessage;
    if (error && (error.userInfo[@"msg"] || error.userInfo[@"message"])) {
        str = error.userInfo[@"msg"] ? error.userInfo[@"msg"] : error.userInfo[@"message"];
    }

    [MBProgressHUD topShowTmpMessage:str];
}

void alertPoolnetError()
{
    [MBProgressHUD topShowTmpMessage:BYMSG_POOR_NETWORK];
}

void alertPushSimplely(NSString* info)
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:info message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -

void runOnMainQueue(void (^block)(void))
{
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void runOnBackgroundQueue(void (^block)(void))
{
    dispatch_async(dispatch_get_main_queue(), block);
}

void runBlockAfterDelay(float delaySeconds, void (^block)(void))
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void runBlockWithRetryTimes(NSUInteger retryTimes, CGFloat delayTime, BOOL (^block)())
{
    NSCAssert(block, @"block不能为空");

    if (retryTimes > 0) {
        BOOL hasDone = block();
        if (!hasDone) {
            runBlockAfterDelay(delayTime, ^{
                runBlockWithRetryTimes(retryTimes - 1, delayTime, block);
            });
        }
    }
}
