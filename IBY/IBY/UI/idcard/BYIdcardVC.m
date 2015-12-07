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

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *ensureButton;

@end

static CGFloat bigTipsFontSize = 16;
static CGFloat smallTipsFontSize = 12;
static CGFloat leftSpace = 37;


@implementation BYIdcardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"身份信息";
//    self.view.backgroundColor = [UIColor grayColor];
    //18518318508
    [self setupUI];
}

#pragma mark - UI
- (void)setupUI {
    CGFloat label_h = 16;
    CGFloat textField_w = SCREEN_WIDTH - 2 * leftSpace;
    CGFloat textField_h = 40;
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, 20, 200, label_h)];
    _nameLabel.text = @"姓名";
    _nameLabel.textColor = BYColor333;
    _nameLabel.font = [UIFont systemFontOfSize:bigTipsFontSize];
    [self.view addSubview:_nameLabel];
    
    CGFloat nameTxf_y = _nameLabel.bottom + 12;
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftSpace, nameTxf_y, textField_w, textField_h)];
    _nameTextField.placeholder = @"  请输入您的姓名";
    _nameTextField.backgroundColor = BYColorWhite;
    _nameTextField.layer.cornerRadius = 5;
    _nameTextField.layer.masksToBounds = YES;
    _nameTextField.layer.borderWidth = 1;
    _nameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:_nameTextField];

    CGFloat numLabel_y = _nameTextField.bottom + 12;
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, numLabel_y, 200, label_h)];
    _numberLabel.text = @"身份证号";
    _numberLabel.textColor = BYColor333;
    _numberLabel.font = [UIFont systemFontOfSize:bigTipsFontSize];
    [self.view addSubview:_numberLabel];

    CGFloat numTxf_y = _numberLabel.bottom + 12;
    _numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftSpace, numTxf_y, textField_w, textField_h)];
    _numberTextField.placeholder = @"  请输入您的身份证号";
    _numberTextField.backgroundColor = BYColorWhite;
    _numberTextField.layer.cornerRadius = 5;
    _numberTextField.layer.masksToBounds = YES;
    _numberTextField.layer.borderWidth = 1;
    _numberTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:_numberTextField];

    CGFloat uploadBtn_w = 60;
    CGFloat uploadBtn_x = _nameTextField.right - uploadBtn_w;
    CGFloat uploadBtn_y = _numberTextField.bottom + 12;
    _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadButton.frame = CGRectMake(uploadBtn_x, uploadBtn_y, uploadBtn_w, 40);
    _uploadButton.backgroundColor = BYColorf60;
    [_uploadButton setTitle:@"上传" forState:UIControlStateNormal];
    _uploadButton.layer.cornerRadius = 5;
    _uploadButton.layer.masksToBounds = YES;
    [_uploadButton addTarget:self
                      action:@selector(selectIdcardImg:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_uploadButton];

    _imageLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, 0, 200, label_h)];
    _imageLabel.centerY = _uploadButton.centerY;
    _imageLabel.text = @"身份证照片(正面)";
    _imageLabel.textColor = BYColor333;
    _imageLabel.font = [UIFont systemFontOfSize:bigTipsFontSize];
    [self.view addSubview:_imageLabel];
    
    CGFloat imgView_y = _uploadButton.bottom + 10;
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftSpace, imgView_y, textField_w, textField_w * 0.6)];
    _imgView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_imgView];
    
    CGFloat proLabel_y = _imgView.bottom + 10;
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace - 6, proLabel_y, 8, label_h)];
    _promptLabel.text = @"*";
    _promptLabel.font = [UIFont systemFontOfSize:smallTipsFontSize];
    _promptLabel.textColor = BYColorFF4C4C;
    [self.view addSubview:_promptLabel];
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, proLabel_y, textField_w, label_h * 2)];
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.text = @"请务必上传与所填写姓名、身份证号一直的身份证正面照片，且身份证上的信息清晰可见";
    _tipsLabel.font = [UIFont systemFontOfSize:smallTipsFontSize];
    _tipsLabel.textColor = BYColor666;
    [self.view addSubview:_tipsLabel];
    
    CGFloat ensuerBtn_y = _tipsLabel.bottom + 12;
    _ensureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _ensureButton.frame = CGRectMake(leftSpace, ensuerBtn_y, textField_w, 40);
    _ensureButton.backgroundColor = BYColorf60;
    [_ensureButton setTitle:@"确定" forState:UIControlStateNormal];
    _ensureButton.layer.cornerRadius = 5;
    _ensureButton.layer.masksToBounds = YES;
    [_ensureButton addTarget:self
                      action:@selector(ensureBtnAction:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _ensureButton];
}


#pragma mark - Action
- (void)selectIdcardImg:(UIButton *)uploadBtn {
    BYLog(@"选择身份证");
}

- (void)ensureBtnAction:(UIButton *)ensuerBtn {
    BYLog(@"确定信息");
}

@end







