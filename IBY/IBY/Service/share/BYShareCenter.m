//
//  BYShareCenter.m
//  IBY
//
//  Created by panshiyu on 15/1/20.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYShareCenter.h"
#import "BYShareUnit.h"
#import "SAKShareKit.h"

#import "BYDesign.h"

#import <SDWebImageDownloader.h>

@implementation BYShareCenter

+ (instancetype)shareCenter
{
    static BYShareCenter* center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] init];
    });
    return center;
}

- (void)shareDesign:(BYDesign*)design fromVC:(UIViewController*)fromVC
{
    BYShareSheet* sheet = [BYShareSheet createPopoverView];
    sheet.designId = design.designId;
    sheet.fromVC = fromVC;

    NSString* url = design.imageUrl;
    if (design.cutImgUrls.count > 6) {
        url = design.cutImgUrls[6];
    }

    sheet.imgPath = url;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage* image, NSData* data, NSError* error, BOOL finished) {
        sheet.image = image;
    }];

    [sheet showInView:nil];
}

- (void)shareDesign:(BYDesign*)design title:(NSString*)title desc:(NSString*)desc fromVC:(UIViewController*)fromVC action:(actionBlock)actionBlk
{
    BYShareSheet* sheet = [BYShareSheet createPopoverView];
    sheet.designId = design.designId;
    sheet.fromVC = fromVC;
    [sheet addTopViewWithTitle:title desc:desc];
    sheet.actionBlk = actionBlk;

    NSString* url = design.imageUrl;
    if (design.cutImgUrls.count > 6) {
        url = design.cutImgUrls[6];
    }

    sheet.imgPath = url;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage* image, NSData* data, NSError* error, BOOL finished) {
        sheet.image = image;
    }];

    [sheet showInView:nil];
}

- (void)shareFromWebBymedia:(int)index
                      title:(NSString*)title
                    content:(NSString*)content
                     imgUrl:(NSString*)imgUrl
                        url:(NSString*)url
                     fromVC:(UIViewController*)fromVC{
    
    [MBProgressHUD topShow:@""];
    
    //需要从web端设置的对应表，设置回本地对应表
    int shareMediaIndex = SAKShareMediaWeixin;
    switch (index) {
        case 1:
            shareMediaIndex = SAKShareMediaQzone;
            break;
        case 2:
            shareMediaIndex = SAKShareMediaSinaWeibo;
            break;
        case 5:
            shareMediaIndex = SAKShareMediaWeixin;
            break;
        case 6:
            shareMediaIndex = SAKShareMediaWeixinFriends;
            break;
        case 7:
            shareMediaIndex = SAKShareMediaSMS;
            break;
        case 8:
            shareMediaIndex = SAKShareMediaQQClient;
            break;
        default:
            break;
    }
    
    if([SAKShareEngine isShareMediaAvailable:shareMediaIndex] != SAKShareMediaAvailable){
        
        [MBProgressHUD topShowTmpMessage:@"您的设备暂不支持此分享方式"];
        return;
    }
    
//    void (^reshootPhotoBlock)(void)
    void (^doShare)(UIImage *image) = ^(UIImage *willShareImg){
        BYShareUnit* unit = [BYShareUnit shareUnitByMedia:shareMediaIndex
                                                    title:title
                                                  content:content
                                                detailURL:url
                                               thumbImage:willShareImg
                                                 thumbURL:imgUrl
                                                     logo:[UIImage imageNamed:@"icon_login_logo"]];
        [SAKShareEngine share:unit from:fromVC willShare:^{
            BYLog(@"will shared");
        } didShare:^(NSError* error) {
            NSString *desc = error ? [error description] : @"Success";
            BYLog(@"share end %@", desc);
        }];
    };
    
    if ([BYAppCenter sharedAppCenter].isNetConnected) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imgUrl] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage* image, NSData* data, NSError* error, BOOL finished) {
            [MBProgressHUD topHide];
            
            UIImage *willShareImg = image ? image : [UIImage imageNamed:@"icon_login_logo"];
            doShare(willShareImg);
        }];
    }else{
        UIImage *willShareImg = [UIImage imageNamed:@"icon_login_logo"];
        doShare(willShareImg);
    }
    

}

@end
