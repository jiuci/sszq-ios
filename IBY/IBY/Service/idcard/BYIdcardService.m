//
//  BYIdcardService.m
//  IBY
//
//  Created by chenglei on 15/12/7.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYIdcardService.h"
//#import "BYUserEngine.h"
#import "BYNetwork.h"

@implementation BYIdcardService


- (void)uploadIdcardImg:(NSData *)imgFile
                  finsh:(void (^)(NSDictionary *data, BYError* error))finished {

    
    NSString* url = SSZQAPI_IDCARD_IMGUPLOAD;

    NSDictionary* params = @{@"imgFile" :imgFile};
    
//    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",@"WebKitFormBoundary"];
//    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",@"SSZQIdcardImageUpload"];
//    
//    //http body的字符串
//    NSMutableString *body=[[NSMutableString alloc] init];
//
//    //参数的集合的所有key的集合
//    NSArray *keys= [params allKeys];
//    
//    //遍历keys
//    for (int i=0;i<[keys count];i++) {
//        //得到当前key
//        NSString *key=[keys objectAtIndex:i];
//        
//        //添加分界线，换行
//        [body appendFormat:@"%@\r\n",MPboundary];
//        //添加字段名称，换2行
//        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
//        //添加字段的值
//        [body appendFormat:@"%@\r\n",[params objectForKey:key]];
//        
//    }
//    
//    if (imgFile) {
//        [body appendFormat:@"%@\r\n",MPboundary];
//        
//        //声明pic字段，文件名为boris.png
//        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"imgFile", @"idcardImg.png"];
//        //声明上传文件的格式
//        [body appendFormat:@"Content-Type: image/jpge, image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
//    }
    
    
    
    [BYNetwork postDataCompleteUrl:url
                            params:params
                            finish:^(NSDictionary *data, BYError *error) {
                                if (error) {
                                    finished(data, error);
                                    return;
                                }
                                BYLog(@"data:%@", data);
                                finished(data, nil);
                            }];
}



- (void)uploadIdcardPutCasherInfoWithUserId:(NSString *)userId
                                       name:(NSString *)name
                                       code:(NSString *)code
                                identityUrl:(NSString *)identityUrl
                                      finsh:(void (^)(NSDictionary *data, BYError* error))finished {

    NSString* url = SSZQAPI_IDCARD_INFOUPLOAD;
    
    NSDictionary* params = @{@"userId": userId,
                             @"name": name,
                             @"code": code,
                             @"identityUrl": identityUrl};
    
    
    [BYNetwork postAppendParamsCompleteUrl:url
                                    params:params
                                    finish:^(NSDictionary *data, BYError *error) {
                                        BYLog(@"data:%@", data);
                                    }];
}


@end
