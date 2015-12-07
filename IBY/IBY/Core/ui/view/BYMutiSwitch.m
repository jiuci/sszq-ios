//
//  BYMutiSwitch.m
//  IBY
//
//  Created by panshiyu on 14-10-22.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYMutiSwitch.h"

@implementation BYMutiSwitch {
    NSMutableArray* _btns;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _btns = [NSMutableArray array];

        UIImageView* backView = [[UIImageView alloc] initWithFrame:self.bounds];
        backView.image = [[UIImage imageNamed:@"bg_tab"] resizableImage];
        [self addSubview:backView];
        _backView = backView;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString*)title handler:(BYSwitchHandler)handler
{
    UIButton* aButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 88, 26)];
    aButton.backgroundColor = BYColorClear;
    [aButton setTitle:title forState:UIControlStateNormal];
    aButton.titleLabel.font = Font(15);
    [aButton setTitleColor:HEXCOLOR(0xb793ff) forState:UIControlStateNormal];
    [aButton setTitleColor:BYColorWhite forState:UIControlStateSelected];
    [aButton setBackgroundImage:nil forState:UIControlStateNormal];
    [aButton setBackgroundImage:[[UIImage imageNamed:@"icon_btn_default.9"] resizableImage] forState:UIControlStateSelected];
    [aButton bk_addEventHandler:^(id sender) {
        for (UIButton *aBtn in _btns) {
            aBtn.selected = NO;
        }
        
        aButton.selected = YES;
        handler(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:aButton];

    [_btns addObject:aButton];

    [self resetDisplay];
}

- (void)addButtonWithBtn:(UIButton*)btn handle:(BYSwitchHandler)handler {

    [btn bk_addEventHandler:^(id sender) {
        for (UIButton *aBtn in _btns) {
            aBtn.selected = NO;
        }
        
        btn.selected = YES;
        handler(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    [_btns addObject:btn];
    
    [self resetDisplay];
}

- (void)setSelectedAtIndex:(int)aIndex
{
    if (aIndex > _btns.count || aIndex < 0) {
        return;
    }
    
    for (UIButton *aBtn in _btns) {
        aBtn.selected = NO;
    }
    
    UIButton* btn = _btns[aIndex];
    btn.selected = YES;
}

- (void)resetDisplay
{
    float aWidth = self.width / [_btns count];
    for (NSInteger i = 0; i < _btns.count; i++) {
        UIButton* aButton = _btns[i];
        aButton.frame = CGRectMake(aWidth * i + 1, 1, aWidth - 2, self.height-2);
    }
}


@end



