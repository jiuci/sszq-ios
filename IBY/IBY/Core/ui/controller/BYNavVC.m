//
//  BYNavigationController.m
//  IBY
//
//  Created by coco on 14-9-11.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYNavVC.h"

@interface BYNavVC () <UINavigationControllerDelegate>
@property (nonatomic, assign, readonly) BOOL isLocked;

@end

@implementation BYNavVC

+ (instancetype)nav:(UIViewController*)viewController
              title:(NSString*)title
{
    BYNavVC* nav = [[BYNavVC alloc] initWithRootViewController:viewController];
    nav.rootController = viewController;
    viewController.navigationItem.title = title;

    [nav.navigationBar setBackgroundImage:[[UIImage imageNamed:@"bg_nav"] resizableImage] forBarMetrics:UIBarMetricsDefault];

    NSDictionary* dict = @{ NSForegroundColorAttributeName : HEXCOLOR(0xffffff),
                            NSFontAttributeName : Font(16) };
    nav.navigationBar.titleTextAttributes = dict;

    nav.delegate = nav;

    return nav;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIViewController*)rootController
{
    return [self.viewControllers firstObject];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated
{
    _isLocked = YES;
    return [super popViewControllerAnimated:animated];
}

- (UIViewController*)currentVC{
    UIViewController* topVC = [(BYNavVC*)self topViewController];
    
    if (topVC.presentedViewController) {
        return topVC.presentedViewController;
    }
    else {
        return topVC;
    }
}

- (void)pushViewController:(UIViewController*)viewController
                  animated:(BOOL)animated
{
    if (_isLocked) {
        BYLog(@"can not push nav coz push lock");
        return;
    }

    _isLocked = YES;
    
    // 如果现在push的不是栈底控制器(最先push进来的那个控制器)
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController*)navigationController
      willShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
    if (viewController.navigationItem.leftBarButtonItem == nil && [navigationController viewControllers].count > 1) {
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarItem:^(id sender) {
            [self popViewControllerAnimated:YES];
        }];
    }

    [navigationController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _isLocked = YES;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _isLocked = NO;
    }];
}

- (void)navigationController:(UINavigationController*)navigationController
       didShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
    _isLocked = NO;
}


#pragma mark - 顺手赚钱
- (BOOL)viewControllersExistVC:(Class)vcClass WithVCs:(NSArray *)vcs {
    for (UIViewController *vc in vcs) {
        if ([vc isMemberOfClass:vcClass]) {
            return YES;
        }
    }
    return NO;
}


@end
