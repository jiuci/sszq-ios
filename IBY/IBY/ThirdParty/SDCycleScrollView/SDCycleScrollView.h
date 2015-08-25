//
//  SDCycleScrollView.h
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

/**
 
 *******************************************************
 *                                                      *
 * 感谢您的支持， 如果下载的代码在使用过程中出现BUG或者其他问题    *
 * 您可以发邮件到gsdios@126.com 或者 到                       *
 * https://github.com/gsdios?tab=repositories 提交问题     *
 *                                                      *
 *******************************************************
 
 */


#import <UIKit/UIKit.h>

typedef enum {
    SDCycleScrollViewPageContolAlimentRight,
    SDCycleScrollViewPageContolAlimentCenter
} SDCycleScrollViewPageContolAliment;

@class SDCycleScrollView;

@protocol SDCycleScrollViewDelegate <NSObject>

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

@end

@interface SDCycleScrollView : UIView

@property (nonatomic, strong) NSArray *imageURLsGroup;
@property (nonatomic, strong) NSArray *titlesGroup;
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;
@property (nonatomic, strong) UIImage * placeholderImage;
@property (nonatomic, assign) SDCycleScrollViewPageContolAliment pageControlAliment;
@property (nonatomic, weak) id<SDCycleScrollViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView *mainView;
- (void)stopTimer;
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup;

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imageURLsGroup:(NSArray *)imageURLsGroup placeHolderImage:(UIImage*)placeHolder;

@end
