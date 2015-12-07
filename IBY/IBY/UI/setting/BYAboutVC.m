//
//  BYAboutVC.m
//  IBY
//
//  Created by St on 14-10-22.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYAboutVC.h"
#import "BYMineCell.h"
#import "BYLinearScrollView.h"
#import "BYBaseWebVC.h"

@interface BYAboutVC ()
@property (nonatomic, strong) BYLinearScrollView* bodyView;
@property (nonatomic, strong) UIImageView* logoImageView;
@property (nonatomic, weak) IBOutlet UILabel* rightLabel;
@end

static CGFloat bottomFontSize = 14;


@implementation BYAboutVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于我们";
    [self setupUI];
}

- (void)setupUI
{
    self.view.height = SCREEN_HEIGHT - self.navigationController.navigationBar.height - [[UIApplication sharedApplication] statusBarFrame].size.height;
//    float cellsTop =self.view.height - 20 - 21 - 21 - 16 - 44 * 1;
    CGFloat cellsTop = self.view.height / 2;
    _bodyView = [[BYLinearScrollView alloc] initWithFrame:BYRectMake(0, cellsTop, SCREEN_WIDTH, 44 * 1)];
//    _bodyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bodyView.autoAdjustContentSize = YES;
    _bodyView.minContentSizeHeight = 0;
    [self.view addSubview:_bodyView];
    
    _logoImageView = [[UIImageView alloc]init];
    UIImage * logoImage = [UIImage imageNamed:@"icon_usercenter_logo"];
    [self.view addSubview:_logoImageView];
    _logoImageView.image = logoImage;
    _logoImageView.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    _logoImageView.centerX = SCREEN_WIDTH / 2;
    _logoImageView.centerY = cellsTop / 2;
    
//    [self appendCell:nil
//               title:@"给个好评"
//                 top:0
//                 sel:@selector(onEvaluation)];
//    
//    [self appendCell:nil
//               title:@"关于顺手赚钱"
//                 top:0
//                 sel:@selector(onAbout)];
    
    [self appendCell:nil
               title:@"用户协议"
                 top:0
                 sel:@selector(onProtocol)];
    
//    NSString * str = [NSString stringWithFormat:@"版本号"];
//    BYMineCell* cell = [BYMineCell cellWithTitle:str icon:nil target:self sel:nil];
//    UILabel * label = [[UILabel alloc]initWithFrame:cell.titleLabel.frame];
//    [cell addSubview:label];
//    label.right= cell.width - 12;
//    label.textAlignment = NSTextAlignmentRight;
//    label.font = Font(14);
//    label.textColor = BYColor999;
//    label.text = @"v2.2.6";
//    cell.showRightArrow = NO;
//    cell.showBottomLine = YES;
//    [self.bodyView by_addSubview:cell paddingTop:0];
//   

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.view.height = SCREEN_HEIGHT - self.navigationController.navigationBar.height - [[UIApplication sharedApplication] statusBarFrame].size.height;
//    float cellsTop =self.view.height - 20 - 21 - 21 - 16 - 44 * 3;
//    _logoImageView.centerY = cellsTop / 2;
}
- (void)appendCell:(NSString*)icon title:(NSString*)title top:(CGFloat)top sel:(SEL)selecor
{
    BYMineCell* cell = [BYMineCell cellWithTitle:title icon:icon target:self sel:selecor];
    cell.showRightArrow = YES;
    cell.showBottomLine = YES;
    [self.bodyView by_addSubview:cell paddingTop:top];
    
}

- (void)onEvaluation
{
//    NSString * appstoreUrlString = @"itms-apps://itunes.apple.com/cn/app/id935095138?mt=8";
//    appstoreUrlString = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=935095138";
//    NSURL * url = [NSURL URLWithString:appstoreUrlString];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:url])
//    {
//        [[UIApplication sharedApplication] openURL:url];
//    }
//    else
//    {
//        NSLog(@"can not open");
//    }
}

- (void)onAbout
{
//    BYBaseWebVC* webVC = [[BYBaseWebVC alloc] initWithURL:[NSURL URLWithString:BYURL_ABOUTBIYAO]];
//    webVC.useWebTitle = YES;
//    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)onProtocol
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_SERVICE_PROTOCOL];
    BYBaseWebVC* webVC = [[BYBaseWebVC alloc] initWithURL:[NSURL URLWithString:urlStr]];
    webVC.useWebTitle = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
@end
