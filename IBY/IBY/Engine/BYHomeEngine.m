//
//  BYHomeEngine.m
//  IBY
//
//  Created by kangjian on 15/8/18.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYHomeEngine.h"
#import "BYHomeInfo.h"
@implementation BYHomeEngine
+ (void)loadHomePagefinish:(void (^)(BYHomeInfo * info, BYError* error))finished
{
    NSString* url = @"/home/show/v2";
    
    [BYNetwork post:url params:nil finish:^(NSDictionary* data, BYError* error) {
//        NSLog(@"%@",data);
        if(error){
//            NSLog(@"%@",error);
            finished(nil,error);
            return ;
        }
        BYHomeInfo * homeInfo = [BYHomeInfo homeWithDict:data];
        if (!homeInfo) {
//            BYError* error = [BYError errorWithDomain:@"com.biyao.fu" code:503 userInfo:nil];
            BYError* error = [BYError errorWithDomain:@"com.biyao.sszq" code:503 userInfo:nil];
            finished(nil,error);
            return;
        }
        finished(homeInfo,nil);
    }];
}
@end
