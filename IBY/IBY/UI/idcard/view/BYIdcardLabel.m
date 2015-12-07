//
//  BYIdcardLabel.m
//  IBY
//
//  Created by chenglei on 15/12/3.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYIdcardLabel.h"

@implementation BYIdcardLabel

+ (instancetype)addIdcardLabelWithFrame:(CGRect)frame TextStr:(NSString *)text {
    BYIdcardLabel *instance = [[self alloc] initWithFrame:frame];
    instance.text = text;
    instance.textColor = BYColor333;
    instance.font = [UIFont systemFontOfSize:18];   // 28号字
    return instance;
}


@end
