//
//  BYThemeEngine.m
//  IBY
//
//  Created by forbertl on 15/9/11.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYThemeEngine.h"
#import "BYThemeInfo.h"

@implementation BYThemeEngine
+ (void)loadThemePage:(int)pageNumber type:(int)type finish:(void (^)(BYThemeInfo * info, BYError* error))finished
{
    NSString* url = @"/minisite/query/v1";
    NSDictionary* params = @{ @"cmsCategoryID" : @(pageNumber),
                              @"statusType" : @(type)
                              };
    
    [BYNetwork post:url params:params finish:^(NSDictionary* data, BYError* error) {
        if(error){
            finished(nil,error);
            return ;
        }
//        NSLog(@"%@",data);
        BYThemeInfo * themeInfo = [BYThemeInfo themeWithDict:data];
        if (!themeInfo) {
//            BYError* error = [BYError errorWithDomain:@"com.biyao.fu" code:503 userInfo:nil];
            BYError* error = [BYError errorWithDomain:@"com.biyao.sszq" code:503 userInfo:nil];
            finished(nil,error);
            return;
        }
        finished(themeInfo,nil);
    }];
}
@end
