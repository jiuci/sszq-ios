//
//  BYShareSheet.m
//  IBY
//
//  Created by panshiyu on 14/11/20.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYShareSheet.h"
#import "BYShareUnit.h"
#import "BYShareConfig.h"
#import "SAKShareKit.h"

@implementation BYShareSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)showInView:(UIView*)view
{
    [super showInView:view];
}

- (void)addTopViewWithTitle:(NSString*)title desc:(NSString*)desc
{
    CGSize size = [desc sizeWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(296, 100)];

    UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + 10 + size.height + 10)];
    topView.backgroundColor = HEXCOLOR(0xf5f5f5);

    UILabel* titlelabel = [UILabel labelWithFrame:BYRectMake(12, 0, self.width - 24, 44) font:Font(16) andTextColor:BYColor333];
    titlelabel.text = title;
    [topView addSubview:titlelabel];

    UIImageView* sepLine = makeSepline();
    sepLine.width = titlelabel.width;
    sepLine.left = titlelabel.left;
    sepLine.top = titlelabel.bottom;
    [topView addSubview:sepLine];

    UILabel* descLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 56, SCREEN_WIDTH - 24, size.height)];
    descLabel.numberOfLines = 0;
    descLabel.text = desc;
    [descLabel setFont:[UIFont systemFontOfSize:14]];
    [topView addSubview:descLabel];

    topView.bottom = SCREEN_HEIGHT - 248;
    [self addSubview:topView];
}

- (void)setupUI
{
    UIView* containView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 248, SCREEN_WIDTH, 248)];
    containView.backgroundColor = HEXCOLOR(0xf5f5f5);
    [self addSubview:containView];

    NSArray* arrName = @[
        @"朋友圈",
        @"QQ空间",
        @"微信好友",
        @"微博",
        @"QQ好友",
        @"短信"
    ];
    NSArray* btnImgName = @[
        @"icon_share_weixinFriends",
        @"icon_share_qzone",
        @"icon_share_weixin",
        @"icon_share_sinaweibo",
        @"icon_share_qq",
        @"icon_share_message"
    ];

    NSArray* btnFlag = @[
        @(SAKShareMediaWeixinFriends),
        @(SAKShareMediaQzone),
        @(SAKShareMediaWeixin),
        @(SAKShareMediaSinaWeibo),
        @(SAKShareMediaQQClient),
        @(SAKShareMediaSMS)
    ];

    for (NSInteger i = 0; i < 6; i++) {
        BYShareCell* cell = [BYShareCell cellWithTitle:arrName[i]
                                                  icon:btnImgName[i]
                                                target:self
                                                   sel:@selector(onShare:)
                                                   tag:[btnFlag[i] intValue]];
        cell.left = 16 + 80 * (i % 4);
        cell.top = 16 + 90 * (i / 4);
        [containView addSubview:cell];
    }

    //画曲线
    //    UIImageView* line = makeSepline();
    //    line.bottom = containView.height - 45;
    //    [containView addSubview:line];

    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
    cancelBtn.bottom = containView.height;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [cancelBtn setTitleColor:BYColor666 forState:UIControlStateNormal];

    [cancelBtn setBackgroundImage:[[UIImage imageNamed:@"btn_white"] resizableImage] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[[UIImage imageNamed:@"btn_whit_on"] resizableImage] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [containView addSubview:cancelBtn];
}

- (void)onShare:(UIButton*)btn
{
    if (_actionBlk) { //若有  需要执行的 才做
        switch (btn.tag) {
        case SAKShareMediaQzone:
            _actionBlk(1);
            break;
        case SAKShareMediaSinaWeibo:
            _actionBlk(2);
            break;
        case SAKShareMediaWeixin:
            _actionBlk(5);
            break;
        case SAKShareMediaWeixinFriends:
            _actionBlk(6);
            break;
        case SAKShareMediaSMS:
            _actionBlk(7);
            break;
        case SAKShareMediaQQClient:
            _actionBlk(8);
            break;
        case SAKShareMediaQQWeibo:
            _actionBlk(9);
            break;
        default:
            break;
        }
    }

    NSInteger tag = btn.tag;
    int index = (int)tag;
    BYShareUnit* unit = [BYShareUnit shareUnitByMedia:index
                                                title:@"分享"
                                              content:@"其实我是设计师这种事我会乱讲吗，瞧瞧我为自己设计的漂亮鞋子"
                                            detailURL:[BYURL_M_DetailDesign appendNum:_designId]
                                           thumbImage:self.image
                                             thumbURL:self.imgPath
                                                 logo:[UIImage imageNamed:@"icon_login_logo"]];
    [SAKShareEngine share:unit from:self.fromVC willShare:^{
        BYLog(@"will shared");
    } didShare:^(NSError* error) {
        NSString *desc = error ? [error description] : @"Success";
        BYLog(@"share end %@", desc);
    }];
    [self hide];
}

- (void)btnAction:(UIButton*)button
{
    button.selected = !button.selected;
    UIImageView* imgView = (UIImageView*)[button viewWithTag:100];
    imgView.highlighted = button.isSelected;
}

- (void)cancelBtnAction
{
    [self hide];
}

@end

@implementation BYShareCell

+ (instancetype)cellWithTitle:(NSString*)title
                         icon:(NSString*)icon
                       target:(id)target
                          sel:(SEL)sel
                          tag:(int)tag
{
    return [[self alloc] initWithFrame:BYRectMake(0, 0, 52, 90)
                                 title:title
                                  icon:icon
                                target:target
                                   sel:sel
                                   tag:tag];
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString*)title
               icon:(NSString*)icon
             target:(id)target
                sel:(SEL)sel
                tag:(NSInteger)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
        btn.tag = tag;
        [self addSubview:btn];

        UILabel* titleLabel = [UILabel labelWithFrame:BYRectMake(0, btn.bottom + 6, 52, 16) font:Font(12) andTextColor:BYColor333];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        [self addSubview:titleLabel];
    }
    return self;
}

@end
