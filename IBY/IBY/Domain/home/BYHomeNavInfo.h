//
//  BYHomeBarNodesInfo.h
//  IBY
//
//  Created by 张经兰 on 15/10/15.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYHomeNavInfo : NSObject
@property(nonatomic, copy)NSString * name;
@property(nonatomic, copy)NSString * imgurl;
@property(nonatomic, copy)NSString * link;

@property(nonatomic, strong)BYHomeNavInfo *navInfo;
@property(nonatomic, copy)NSArray * secondArray;
@property (nonatomic, assign) BOOL opened;

@end
