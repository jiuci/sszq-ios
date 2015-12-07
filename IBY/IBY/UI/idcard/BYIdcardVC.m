//
//  BYIdcardVC.m
//  IBY
//
//  Created by chenglei on 15/12/3.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYIdcardVC.h"

#import "BYIdcardLabel.h"
#import "BYIdcardButton.h"

@interface BYIdcardVC ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UITextField *numberTextField;
@property (nonatomic, strong) UILabel *imageLabel;
@property (nonatomic, strong) UIButton *uploadButton;

@property (nonatomic, strong) UIImageView *idcardImgView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *ensureButton;

@end

static CGFloat bigTipsFontSize = 14;
static CGFloat smallTipsFontSize = 12;


@implementation BYIdcardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"身份信息";
    
    [self setupUI];
}

#pragma mark - UI
- (void)setupUI {
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.text = @"姓名";
    _nameLabel.textColor = BYColor333;
    [self.view addSubview:_nameLabel];
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _numberLabel.text = @"身份证号";
    _numberLabel.textColor = BYColor333;
    [self.view addSubview:_numberLabel];

    _imageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _imageLabel.text = @"身份证照片(正面)";
    _imageLabel.textColor = BYColor333;
    [self.view addSubview:_imageLabel];

    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 200, 200, 50)];
    _nameTextField.placeholder = @"请输入您的姓名";
    [self.view addSubview:_nameTextField];
    
    _numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 200, 200, 50)];
    _numberTextField.placeholder = @"请输入您的身份证号";
    [self.view addSubview:_numberTextField];

    
}



@end







