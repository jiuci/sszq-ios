//
//  BYIdcardService.h
//  IBY
//
//  Created by chenglei on 15/12/7.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYBaseService.h"

@interface BYIdcardService : BYBaseService

/*
 post 参数：imgFile-上传的文件名
 身份证上传地址：sf-share.admin.biyao.com/file/upload.do
 
 post参数：name-身份证姓名，code-身份证号 ，identityUrl-身份证照片url
 finance.biyao.com/wxcash/putCasherInfo?name=*&code=*&identityUrl=*
 
 finance.biyao.com/wxcash/putCasherInfo?userId=8&name=*&code=*&identityUrl=*
 */

@property (nonatomic, strong) NSData *imgFile;  // 上传图片

@property (nonatomic, copy) NSString *userId;   //
@property (nonatomic, copy) NSString *name; // 身份证姓名
@property (nonatomic, copy) NSString *code; // 身份证号
@property (nonatomic, copy) NSString *identityUrl;  // 身份证照片url


/**
 *  点击“上传”，向服务器上传图片
 *
 *  @param imgFile  图片文件
 *  @param finished 完成回调block
 */
- (void)uploadIdcardImg:(NSData *)imgFile
                  finsh:(void (^)(NSDictionary *data, BYError* error))finished;


/**
 *  点击“确定”，向服务器上传身份证填写页的所有信息
 *
 *  @param userId      userId
 *  @param name        身份证姓名
 *  @param code        身份证号
 *  @param identityUrl 身份证照片url
 *  @param finished    完成回调block
 */
- (void)uploadIdcardPutCasherInfoWithUserId:(NSString *)userId
                                       name:(NSString *)name
                                       code:(NSString *)code
                                    identityUrl:(NSString *)identityUrl
                                      finsh:(void (^)(NSDictionary *data, BYError* error))finished;




@end
