//
//  BYAppCenter.m
//  IBY
//
//  Created by coco on 14-9-22.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYAppCenter.h"
#import "MJExtension.h"
#import "BYAppService.h"
#import "BYUserService.h"
#import "CommonFunc.h"

#import "Reachability.h"
#import <EaseMobSDK/EaseMob.h>

#define CACHE_EXPIRED_TIME (60 * 1 * 1)
#define SECONDS_PER_HOUR (60 * 60 * 1)
#define kBYUpgradeFlag @"com.biyao.upgradeFlag"

NSString* const BYAppLoginNotification = @"com.biyao.login";
NSString* const BYAppLogoutNotification = @"com.biyao.logout";
NSString* const BYAppShakeNotification = @"com.biyao.app.shake";
NSString* const BYAppWeixinAuthNotification = @"com.biyao.weixin.auth";
NSString* const BYAppSessionInvalidNotification = @"com.biyao.app.sessionInvalid";


@interface BYAppCenter ()
@property (nonatomic, strong) BYAppService* appService;
@property (nonatomic, strong) BYUserService* userService;
@property (nonatomic, strong) Reachability* wifiReachability;

@end

@implementation BYAppCenter

+ (instancetype)sharedAppCenter
{
    static BYAppCenter* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setupConfiguration
{
    _uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    _visitCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"visitCode"];

    _user = nil;

    NSDictionary* userCache = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if (userCache) {
        _user = [BYUser mtlObjectWithKeyValues:userCache];
    }

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"appinfo" ofType:@"plist"];
    NSDictionary* appinfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
    _appName = appinfo[@"appName"];
    _appVersion = appinfo[@"appVersion"];
    _platform = appinfo[@"platform"];
    _channel = appinfo[@"channel"];
    _numVersion = [appinfo[@"numVersion"] intValue];
    _payPlatform = @"mobile";

    _appService = [[BYAppService alloc] init];
    _userService = [[BYUserService alloc] init];

    _wifiReachability = [Reachability reachabilityForLocalWiFi];
    [_wifiReachability startNotifier];

    [self didActive];
    
    _isNetConnected = YES;
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.biyao.com"];
    reach.reachableBlock = ^(Reachability * reachability)
    {
        if ([reachability isReachableViaWiFi]) {
            setCookies(@"__net", @"WIFI");
        }else if([reachability isReachableViaWWAN]){
            setCookies(@"__net", @"WWAN");
        }
        
        _isNetConnected = YES;
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        _isNetConnected = NO;
    };
    [reach startNotifier];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSessionInvalid) name:BYAppSessionInvalidNotification object:nil];
    
}

- (void)updateUidAndToken{
    //check cookie
    NSArray* cookiesArray = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    NSString *cookieUid = nil;
    NSString *cookieToken = nil;
    
    for (NSHTTPCookie* cookie in cookiesArray) {
        NSDictionary* dic =  cookie.properties;
        if([dic[NSHTTPCookieName] isEqualToString:@"uid"]){
            cookieUid = dic[NSHTTPCookieValue];
        }
        if([dic[NSHTTPCookieName] isEqualToString:@"token"]){
            cookieToken = dic[NSHTTPCookieValue] ;
        }
    }
    
    //user
    
    if (!_user) {
        _user = [[BYUser alloc]init];
    }
    
    if (cookieUid && cookieToken) {
        _user.userID = [cookieUid intValue];
        //cookie中做了urlencoding
        _user.token = [cookieToken URLDecodedString];
    }else{
        _user = nil;
    }
}

- (void)doUpgradeIfNeeded
{
    NSDictionary* upgradeMap = [[NSUserDefaults standardUserDefaults] objectForKey:kBYUpgradeFlag];
    BOOL hasUpgrade = [upgradeMap[self.appVersion] boolValue];
    if (!hasUpgrade) {
        hasUpgrade = YES;
        NSMutableDictionary* bmap = [NSMutableDictionary dictionary];
        if (upgradeMap) {
            bmap = [upgradeMap mutableCopy];
        }

        bmap[self.appVersion] = @(hasUpgrade);
        [[NSUserDefaults standardUserDefaults] setObject:bmap forKey:kBYUpgradeFlag];
        [[NSUserDefaults standardUserDefaults] synchronize];

        _user = nil;
        resetCookies();
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didActive
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:-CACHE_EXPIRED_TIME];
    [[TMCache TemporaryCache] trimToDate:date block:^(TMCache* cache) {
        BYLog(@"");
    }];
    
    //现在token不是客户端维护，不必再做检测
//    [_userService refreshToken:^(BOOL isSuccess, BYError *error) {
//        if (!isSuccess) {
//            NSLog(@"logout");
//            [[BYAppCenter sharedAppCenter] logout];
//        }
//    }];
}

- (void)logout
{
    _user = nil;
    resetCookies();
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
    } onQueue:nil];
//    inputCookies();
    [[NSNotificationCenter defaultCenter] postNotificationName:BYAppLogoutNotification object:nil];

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateUserLatestStatus:(void (^)(BOOL isSuccess, BYError* error))finished
{
    if (!self.isLogin) {
        finished(NO, nil);
        return;
    }

    [_userService fetchUserLatestStatus:^(BOOL isSuccess, BYError* error) {
        finished(isSuccess,error);
    }];
}

- (void)checkVersionInfo
{
    //开机只检测强制升级功能
    [_appService checkAppNeedUpdate:^(BYVersionInfo* versionInfo, BYError* error) {
        if (versionInfo) {
            if (versionInfo.forceUpdate) {
                UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"有新版本啦！" message:@"立即升级获得更赞的购物体验！"];
                [alert bk_addButtonWithTitle:@"立即升级" handler:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionInfo.url]];
                }];
                [alert show];
            }
        }
    }];
}
- (void)receivedPushInActive:(int)isactive
{
    [_appService receivedPushInActive:isactive finished:^(BOOL success, BYError* error) {
        if (success) {
        }
    }];
}
- (void)uploadToken:(NSString*)token
{
    
    int oldUid = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"com.biyao.push.last.uid"];
    if (oldUid == [BYAppCenter sharedAppCenter].user.userID || ![BYAppCenter sharedAppCenter].isLogin) {
        return;
    }
//    NSString* pushTokenKey = [NSString stringWithFormat:@"com.biyao.push.token.uid:%d",[BYAppCenter sharedAppCenter].user.userID];//[@"com.biyao.push.token" append:token];
//    BOOL hasSent = [[[NSUserDefaults standardUserDefaults] objectForKey:pushTokenKey] boolValue];
//    if (hasSent) {
//        return;
//    }

    if (!token) {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.biyao.push.token"];
    }
//    token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (!token) {
        return;
    }
   
    [_appService uploadToken:token finished:^(BOOL success, BYError* error) {
        if (success) {
            [[NSUserDefaults standardUserDefaults]setInteger:[BYAppCenter sharedAppCenter].user.userID forKey:@"com.biyao.push.last.uid"];
           // [[NSUserDefaults standardUserDefaults]setObject:@(YES) forKey:pushTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            BYLog(@"userID：%d", [BYAppCenter sharedAppCenter].user.userID);
            BYLog(@"token成功：%@", token);
        }else {
            BYLog(@"token失败：%@", token);
        }
    }];
}

- (void)didLogin:(BYUser*)user
{
    if (!user) {
        return;
    }

    _user = user;

    inputCookies();
    [[NSNotificationCenter defaultCenter] postNotificationName:BYAppLoginNotification object:nil];

    [[NSUserDefaults standardUserDefaults] setObject:_user.mtlJsonDict forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isLogin
{
    if (_user && [_user isValid]) {
        return YES;
    }
    return NO;
}
- (void)runAfterLoginFromVC:(UIViewController*)vc withBlk:(BYLoginSuccessBlock)blk
{
    BYLoginCancelBlock cblk = ^{};
    [self runAfterLoginFromVC:vc withSuccessBlk:blk cancelBlk:cblk];
}
- (void)runAfterLoginFromVC:(UIViewController*)vc withSuccessBlk:(BYLoginSuccessBlock)blk cancelBlk:(BYLoginCancelBlock)cblk
{
    if (self.isLogin) {
        blk();
    }
    else {
        [vc.navigationController presentViewController:makeLoginnav(blk, cblk) animated:YES completion:nil];
    }
}

#pragma mark - push

- (void)invalidPushId {
    _pushId = @"0";
}

- (void)onSessionInvalid {
    [self invalidPushId];
}

#pragma mark - network

static NSString* kNetworkRemindAllTimes = @"com.biyao.networkReminding.allTimes";
static NSString* kNetworkRemindLastTimes = @"com.biyao.networkReminding.lastTimes";
static int kNetworkRemindMaxTimes = 3;
- (void)checkNetworkStatus
{
    int allTimes = [[[NSUserDefaults standardUserDefaults] objectForKey:kNetworkRemindAllTimes] intValue];

    if (allTimes > kNetworkRemindMaxTimes) {
        return;
    }

    NSNumber* lastRemindTime = [[NSUserDefaults standardUserDefaults] objectForKey:kNetworkRemindLastTimes];
    BOOL canRemindAgain = YES;
    if (lastRemindTime) {
        NSDate* lastDate = [NSDate dateWithTimeIntervalSince1970:[lastRemindTime doubleValue]];
        NSDate* currentDate = [NSDate date];
        if ([currentDate timeIntervalSinceDate:lastDate] < 60 * 60 * 24) {
            //如果间隔小于1天
            canRemindAgain = NO;
        }
    }

    if (!canRemindAgain) {
        return;
    }

    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    //    BOOL connectionRequired = [self.wifiReachability connectionRequired];
    //这个东西是有用的，某些网络虽然连接了，但是上不了网，还是可以使用这个字段

    if (netStatus != ReachableViaWiFi) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@([[NSDate date] timeIntervalSince1970]) forKey:kNetworkRemindLastTimes];
        [userDefaults setObject:@(++allTimes) forKey:kNetworkRemindAllTimes];
        [userDefaults synchronize];

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"当前为非WIFI网络" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark -

- (NSString*)uuid
{
    if (!_uuid) {
        //自动创建一个uuid，以后存起来用
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        _uuid = (__bridge_transfer NSString*)string;

        [[NSUserDefaults standardUserDefaults] setObject:_uuid forKey:@"uuid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return _uuid;
}

- (NSString*)systemVersion
{
    if (!_systemVersion) {
        _systemVersion = [NSString stringWithFormat:@"%@%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
        ;
    }
    return _systemVersion;
}

- (NSString*)deviceType
{
    if (!_deviceType) {
        _deviceType = [UIDevice currentDevice].model;
    }
    return _deviceType;
}


static int kAppLiftCircle = 60 * 5;
- (NSString*)sessionId
{
    NSNumber* lastEventTime = [BYAnalysis lastEventTime];
    
    BOOL isFirstVisit = (_sessionId == nil);

    if (_sessionId && lastEventTime) {

        NSDate* lastDate = [NSDate dateWithTimeIntervalSince1970:[lastEventTime doubleValue]];
        NSDate* currentDate = [NSDate date];
        if ([currentDate timeIntervalSinceDate:lastDate] < kAppLiftCircle) {
            //如果间隔小于10分钟
            return _sessionId;
        }
    }

    int ranNum = arc4random() % 1000;
    NSString* oriStr = [NSString stringWithFormat:@"%@%@%d%d", self.uuid, [[NSDate date] dateStringWithFormat:BYDateFormatyyyyMMddHHmm], ranNum, (self.user ? self.user.userID : -1)];
    _sessionId = [oriStr generateMD5];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:BYAppSessionInvalidNotification object:nil];
    if (!isFirstVisit) {
        [self onSessionInvalid];
    }
    
    return _sessionId;
}

- (NSString*)visitCode
{
    if (!_visitCode) {
        NSString* dateStr = [[NSDate date] dateStringWithFormatString:@"yyyy-MM-dd HH:mm:ss"];
        NSDictionary* dict = @{ @"visitCode" : self.uuid,
                                @"writeTime" : dateStr
        };

        _visitCode = [[dict jsonString] BYDESString];

        [[NSUserDefaults standardUserDefaults] setObject:_visitCode forKey:@"visitCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return _visitCode;
}

- (NSString*)pushId {
    if (!_pushId) {
        return @"0";
    }
    return _pushId;
}

- (NSDictionary*)paramsMapForHeader
{
    //set header需要的都是string，so都转换成string格式
    return @{
        @"uuid" : self.uuid,
        @"appName" : _appName,
        @"payplatform" : _payPlatform,
        @"appVersion" : _appVersion,
        @"numVersion" : [@(_numVersion) stringValue],
        @"platform" : _platform,
        @"channel" : _channel,
        @"deviceType" : self.deviceType,
        @"systemVersion" : self.systemVersion,
        @"uid" : [self isLogin] ? [@(_user.userID) stringValue] : @"",
        @"token" : [self isLogin] ? _user.token : @"",
        @"sessionId" : self.sessionId,
        @"dzvisit" : self.visitCode,
        @"pushId" : self.pushId,
    };
}

@end
