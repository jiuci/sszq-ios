//
//  BYPushUnit.h
//  IBY
//
//  Created by panshiyu on 15/2/12.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BYPushTypeDefault = 0,
    BYPushTypeDesignDetail = 1,
    BYPushTypeMWeb = 2
} BYPushType;

@interface BYPushUnit : NSObject

@property (nonatomic, copy) NSString* pushId;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, assign) BYPushType type;
@property (nonatomic, copy) NSDictionary* pushParams;

+ (instancetype)unitWithRemoteInfo:(NSDictionary*)info;
@end






















