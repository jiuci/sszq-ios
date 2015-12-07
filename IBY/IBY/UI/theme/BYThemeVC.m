//
//  BYThemeVC.m
//  IBY
//
//  Created by forbertl on 15/9/11.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYThemeVC.h"
#import "BYThemeService.h"
#import "BYThemeInfo.h"
#import "BYImageView.h"
#import "BYPoolNetworkView.h"
//#import "MJRefresh.h"
//#import "MJRefreshHeaderView.h"
#import "UIViewController+analysis.h"

@interface BYThemeVC ()<UIScrollViewDelegate>
@property (nonatomic, strong)BYThemeService * service;
@property (nonatomic, strong)UIScrollView * scroll;
@property (nonatomic, strong)UIButton * gototop;
@end

@implementation BYThemeVC

+ (instancetype)sharedTheme
{
    static BYThemeVC* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)testThemeWithId:(int)categoryID
{
    BYThemeVC* instance = [BYThemeVC sharedTheme];
    if (instance.categoryID != categoryID) {
        [instance clearUI];
    }
    instance.categoryID = categoryID;
    instance.testType = YES;
    [instance refresh];
    return instance;

}

+ (instancetype)sharedThemeWithId:(int)categoryID
{
    BYThemeVC* instance = [BYThemeVC sharedTheme];
    if (instance.categoryID != categoryID) {
        [instance clearUI];
    }
    instance.categoryID = categoryID;
    instance.testType = NO;
    [instance refresh];
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self refresh];
    // Do any additional setup after loading the view.
}

- (void)setupUI
{
    _service = [[BYThemeService alloc]init];
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 44 -20)];
    [self.view addSubview:_scroll];
    _scroll.delegate = self;
    _scroll.backgroundColor = BYColorBG;
    
    _gototop = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_gototop];
    [_gototop addTarget:self action:@selector(onGototop) forControlEvents:UIControlEventTouchUpInside];
    _gototop.frame = CGRectMake(SCREEN_WIDTH - 12 - 44, SCREEN_HEIGHT - 46 - 20 - 28 - 44, 44, 44);
//    _gototop.backgroundColor = [UIColor blackColor];
    [_gototop setBackgroundImage:[UIImage imageNamed:@"icon_theme_gototop"] forState:UIControlStateNormal];
    _gototop.hidden = YES;
    _gototop.alpha = 0;
    
}

- (void)updateUI
{
    float offset = 0;
    self.title = _info.title;
    for (UIView * view in _scroll.subviews) {
        [view removeFromSuperview];
    }
    [_scroll setContentOffset:CGPointMake(0, 0) animated:NO];
    _gototop.hidden = YES;
    BYHomeInfoSimple * simple = _info.headerInfo;
//    NSLog(@"%d,%d",simple.width,simple.height);
    if (simple.width > 0 && simple.height > 0) {
        BYImageView * header = [[BYImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_WIDTH/ (float)simple.width*simple.height)];
        
        header.jumpURL = simple.link;
        header.image = [UIImage imageNamed:@"bg_placeholder"];
        [header setImageWithUrl:simple.imagePath placeholderName:@"bg_placeholder"];
        [header addTapAction:@selector(onImagetap:) target:header];
        
        [_scroll addSubview:header];
        offset += header.height + 10;
    }
    
    if (_info.layout.intValue == 1) {
        //floor
        offset = [self buildFloorStartWithOffset:offset];
        //product
        offset = [self buildProductStartWithOffset:offset];
    }else if (_info.layout.intValue == 2){
        //product
        offset = [self buildProductStartWithOffset:offset];
        //floor
        offset = [self buildFloorStartWithOffset:offset];
    }
    
    _scroll.contentSize = CGSizeMake(SCREEN_WIDTH, offset);
    
   
}



- (float)buildFloorStartWithOffset:(float)offset
{
    
    float bottom = 0;
    
    for (int i = 0; i < _info.floors.count; i++) {
        BYThemeFloorSimple * floor = _info.floors[i];
        
        if (floor.mainTitle && floor.mainTitle.length) {
            UILabel * mainTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
            mainTitleLabel.text = floor.mainTitle;
            mainTitleLabel.font = Font(16);
            mainTitleLabel.textColor = BYColor333;
            mainTitleLabel.textAlignment = NSTextAlignmentCenter;
            mainTitleLabel.top = offset + 12;
            mainTitleLabel.backgroundColor = [UIColor clearColor];
            [_scroll addSubview:mainTitleLabel];
            offset += 12 + mainTitleLabel.height + 10;
        }
        
        if (floor.subTitle && floor.subTitle.length) {
            UILabel * subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 14)];
            subTitleLabel.text = floor.subTitle;
            subTitleLabel.font = Font(14);
            subTitleLabel.textColor = BYColor666;
            subTitleLabel.textAlignment = NSTextAlignmentCenter;
            subTitleLabel.top = offset;
            subTitleLabel.backgroundColor = [UIColor clearColor];
            [_scroll addSubview:subTitleLabel];
            offset += 12 + subTitleLabel.height;
        }
        
        float interval = 10;
        if (floor.width && floor.height) {
            BYImageView * imageTitle = [[BYImageView alloc]initWithFrame:CGRectMake(0, offset, SCREEN_WIDTH ,SCREEN_WIDTH / (float)floor.width*floor.height)];
            offset += imageTitle.height + interval;
            [imageTitle setImageWithUrl:floor.imageTitle placeholderName:@"bg_placeholder"];
            [_scroll addSubview:imageTitle];
        }
        
        if (floor.column == 0) {
            continue;
        }
        float simpleWidth = (SCREEN_WIDTH - (floor.column + 1) * interval) / floor.column;
        
        for (int j = 0; j < floor.simples.count; j++) {
            BYHomeInfoSimple * simple = floor.simples[j];
            BYImageView * header = [[BYImageView alloc]initWithFrame:CGRectMake(j % floor.column * (simpleWidth + interval) + interval,offset, simpleWidth ,simpleWidth / (float)simple.width*simple.height)];
            
            header.jumpURL = simple.link;
            header.image = [UIImage imageNamed:@"bg_placeholder"];
            [header setImageWithUrl:simple.imagePath placeholderName:@"bg_placeholder"];
            [header addTapAction:@selector(onImagetap:) target:header];
            bottom = header.bottom;
            if ((j+1) % floor.column == 0) {
                offset += header.height + interval;
            }
            [_scroll addSubview:header];
         
        }
        offset = bottom;
        offset += interval;
    }
    
    return offset;
}

- (float)buildProductStartWithOffset:(float)offset
{
    for (int i = 0 ; i < _info.products.count; i++) {
        
        BYHomeInfoSimple * simple = _info.products[i];
        BYImageView * header = [[BYImageView alloc]initWithFrame:CGRectMake(0 ,offset, SCREEN_WIDTH ,SCREEN_WIDTH / (float)simple.width*simple.height)];
        
        header.jumpURL = simple.link;
        header.image = [UIImage imageNamed:@"bg_placeholder"];
        [header setImageWithUrl:simple.imagePath placeholderName:@"bg_placeholder"];
        [header addTapAction:@selector(onImagetap:) target:header];
        offset += header.height;
        [_scroll addSubview:header];
        offset += 12;
    }
    return offset;
}
- (void)refresh
{
    __weak BYThemeVC* wself = self;
    int testType = self.testType ? 0:1;
    [_service loadThemePage:_categoryID type:testType finish:^(BYThemeInfo*info,BYError *error){
        if (!info || error) {
            wself.gototop.hidden = YES;
            if (!wself.info) {
                [wself showPoolnetworkView];
//                [self.tipsView addTapAction:@selector(refresh) target:self];
                UIButton * tapRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
                tapRefresh.frame = CGRectMake(0, 0, wself.tipsView.width, wself.tipsView.height);
                [wself.tipsView addSubview:tapRefresh];
                [tapRefresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
            }
//            [wself.scroll headerEndRefreshing];
            alertError(error);
            return;
        }
        [wself hideTipsView];
        if ([wself.info isSameTo:info]) {
            wself.title = info.title;
//            [wself.scroll headerEndRefreshing];
            return;
        }
        wself.info = info;
        NSString * str = [NSString stringWithFormat:@"mid=%d",wself.categoryID];
        wself.pageParameter = [NSMutableDictionary dictionaryWithObject:str forKey:@"mid"];
        [wself updateUI];
//        NSLog(@"update");
//        [wself.scroll headerEndRefreshing];
    }];
}

- (void)clearUI
{
    for (UIView * view in _scroll.subviews) {
        [view removeFromSuperview];
    }
//    __weak typeof(self) wself = self;
//    [self.scroll addHeaderWithCallback:^{
//        [wself refresh];
//    }];
    self.info = nil;

}

- (void)onGototop
{
    [_scroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float location = scrollView.contentOffset.y;
//    NSLog(@"%f",location / scrollView.height);
    if (location > scrollView.height * 1 && _gototop.hidden == YES) {
        _gototop.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _gototop.alpha = 1;
        } completion:^(BOOL finished){
            
        }];
    }else if(location < scrollView.height * 1 && _gototop.hidden == NO){
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _gototop.alpha = 0;
        } completion:^(BOOL finished){
            _gototop.hidden = YES;
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"setgobackuri");
    [super viewDidAppear:animated];
    if (!self.title || self.title.length == 0) {
        self.title = _info.title;
    }
    addCookies(self.url, @"gobackuri", @".biyao.com");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.title = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
