//
//  BYMutiSwitch.h
//  IBY
//
//  Created by panshiyu on 14-10-22.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BYSwitchHandler)(id sender);

@interface BYMutiSwitch : UIControl
@property (nonatomic,strong)UIImageView *backView;

- (void)addButtonWithTitle:(NSString*)title handler:(BYSwitchHandler)handler;
- (void)addButtonWithBtn:(UIButton*)btn handle:(BYSwitchHandler)handler;
- (void)setSelectedAtIndex:(int)aIndex;


@end
