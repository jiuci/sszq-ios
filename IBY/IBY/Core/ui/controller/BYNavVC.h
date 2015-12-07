//
//  BYNavigationController.h
//  IBY
//
//  Created by coco on 14-9-11.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYNavVC : UINavigationController

@property (nonatomic, strong) UIViewController* rootController;


+ (instancetype)nav:(UIViewController*)viewController title:(NSString*)title;



- (UIViewController*)currentVC;

// 顺手赚钱
- (BOOL)viewControllersExistVC:(Class)vcClass WithVCs:(NSArray *)vcs;


@end
