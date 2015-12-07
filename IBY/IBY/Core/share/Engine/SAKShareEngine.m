//
//  MTShareEngine.m
//  iMeituan
//
//  Created by psy on 13-7-4.
//  Copyright (c) 2013年 Meituan.com. All rights reserved.
//

#import "SAKShareEngine.h"
#import "SAKPipeBase.h"
#import "SAKPipeQQClient.h"
//#import "SAKPipeQQWeibo.h"
//#import "SAKPipeQzone.h"
//#import "SAKPipeSinaWeibo.h"
#import "SAKPipeWeixin.h"
#import "SAKPipeWeixinFriends.h"
#import "SAKPipeSMS.h"
//#import "WeiboSDK.h"

static NSString* shareMethodNames[] = { @"新浪微博", @"QQ空间", @"腾讯微博", @"短信", @"微信", @"微信朋友圈", @"QQ好友" };
static NSString* sharePipeNames[] = {
    @"SAKPipeSinaWeibo",
    @"SAKPipeQzone",
    @"SAKPipeQQWeibo",
    @"SAKPipeSMS",
    @"SAKPipeWeixin",
    @"SAKPipeWeixinFriends",
    @"SAKPipeQQClient",
};

@interface SAKShareData : NSObject
@property (nonatomic, readonly) NSArray* pipesArray;
+ (SAKShareData*)sharedInstance;

@end

@implementation SAKShareEngine

+ (void)enableShareWithConfig:(SAKShareConfig*)config
{
    NSCAssert(config != nil, @"配置对象不能为空");

    [SAKShareConfig sharedInstanceWithConfig:config];
}

#pragma mark - 工具方法

+ (SAKShareMediaAvailability)isShareMediaAvailable:(SAKShareMedia)shareMethod
{
    id<SAKShareMediaProtocol> pipe = [self pipeByMedia:shareMethod];
    return [pipe isAvailable];
}

+ (BOOL)isCapableOfURL:(NSURL*)url
{
    NSString* scheme = [url scheme];
    SAKShareConfig* curConfig = [SAKShareConfig sharedInstance];
    if ([scheme compare:curConfig.qqClientKey options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [scheme compare:curConfig.weixinClientKey options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [scheme compare:curConfig.sinaClientKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+ (void)handleOpenURL:(NSURL*)url didShare:(SAKDidShareBlock)finishBlock
{
    NSString* scheme = [url scheme];
    SAKShareConfig* curConfig = [SAKShareConfig sharedInstance];
    if ([scheme compare:curConfig.qqClientKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        SAKPipeQQClient* qqClient = (SAKPipeQQClient*)[self pipeByMedia:SAKShareMediaQQClient];
        [qqClient handleOpenURL:url didShare:finishBlock];
    }
    else if ([scheme compare:curConfig.weixinClientKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        SAKPipeWeixin* weixin = (SAKPipeWeixin*)[self pipeByMedia:SAKShareMediaWeixin];
        if (!weixin.gotResponse) {
            [weixin handleOpenURL:url didShare:finishBlock];
            return;
        }

        SAKPipeWeixinFriends* weixinFriends = (SAKPipeWeixinFriends*)[self pipeByMedia:SAKShareMediaWeixinFriends];
        if (![weixinFriends gotResponse]) {
            [weixinFriends handleOpenURL:url didShare:finishBlock];
            return;
        }
        /* if both weixin and weixinFriends has no delegate, it means the share was not triggered by meituan,
         * and as currently weixinFriends does not support initiate a sharing, it can only be weixin.
         * however, if things change, remember to FIXME: how to determine who initiates the sharing
         */
        [weixin handleOpenURL:url didShare:finishBlock];
    }
    else if ([scheme compare:curConfig.sinaClientKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//        SAKPipeSinaWeibo* sinaWeibo = (SAKPipeSinaWeibo*)[self pipeByMedia:SAKShareMediaSinaWeibo];
//        [sinaWeibo handleOpenURL:url didShare:finishBlock];
    }
}

#pragma mark -
//http://stackoverflow.com/questions/757059/position-of-least-significant-bit-that-is-set
static int indexByShareMethod(SAKShareMedia shareMethod)
{
    static const int MultiplyDeBruijnBitPosition[32] = {
        0, 1, 28, 2, 29, 14, 24, 3, 30, 22, 20, 15, 25, 17, 4, 8,
        31, 27, 13, 23, 21, 19, 16, 7, 26, 12, 18, 6, 11, 5, 10, 9
    };
    SAKShareMedia firstSetMethod = shareMethod & -shareMethod;
    int index = MultiplyDeBruijnBitPosition[((UInt32)(firstSetMethod * 0x077cb531u)) >> 27];
    return index;
}

+ (id<SAKShareMediaProtocol>)pipeByMedia:(SAKShareMedia)media
{
    int index = indexByShareMethod(media);
    return [SAKShareData sharedInstance].pipesArray[index];
}

+ (id<SAKShareMediaProtocol>)sharePipeByShareMethod:(SAKShareMedia)shareMethod
{
    int index = indexByShareMethod(shareMethod);
    Class pipeClass = NSClassFromString(sharePipeNames[index]);
    id<SAKShareMediaProtocol> pipe = [[pipeClass alloc] init];
    return pipe;
}

+ (NSString*)shareMediaName:(SAKShareMedia)shareMethod
{
    int index = indexByShareMethod(shareMethod);
    return shareMethodNames[index];
}

+ (void)share:(id<SAKSharerProcotol>)sharer
         from:(UIViewController*)fromVC
    willShare:(SAKWillShareBlock)willBlock
     didShare:(SAKDidShareBlock)finishBlock
{
    NSCAssert(finishBlock != nil, @"必须有finishBlock");

    id<SAKShareMediaProtocol> pipe = [self pipeByMedia:[sharer shareMedia]];

    if (willBlock) {
        willBlock();
    }

    [pipe share:sharer from:fromVC willShare:willBlock didShare:finishBlock];
}

@end

@implementation SAKShareData

+ (SAKShareData*)sharedInstance
{
    static SAKShareData* shareData;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareData = [[SAKShareData alloc] init];
    });
    return shareData;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray* aArray = [NSMutableArray array];
        // bug此处为了解决数组越界，暂用办法
        [aArray addObject:[[SAKPipeSMS alloc] init]];
        [aArray addObject:[[SAKPipeSMS alloc] init]];
        [aArray addObject:[[SAKPipeSMS alloc] init]];
        // 以下正常
        [aArray addObject:[[SAKPipeSMS alloc] init]];
        [aArray addObject:[[SAKPipeWeixin alloc] init]];
        [aArray addObject:[[SAKPipeWeixinFriends alloc] init]];
        [aArray addObject:[[SAKPipeQQClient alloc] init]];

        _pipesArray = [NSArray arrayWithArray:aArray];
    }
    return self;
}

@end