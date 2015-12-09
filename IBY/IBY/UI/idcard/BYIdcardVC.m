//
//  BYIdcardVC.m
//  IBY
//
//  Created by chenglei on 15/12/3.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYIdcardVC.h"

#import <MediaPlayer/MediaPlayer.h>

#import "BYIdcardService.h"
#import "BYNextWebVC.h"

#import "RegexKitLite.h"


@interface BYIdcardVC ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UILabel *imageLabel;
@property (nonatomic, strong) UIButton *uploadButton;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *ensureButton;

@property (nonatomic, copy) NSString *identityUrl;

@end

static CGFloat bigTipsFontSize = 16;
static CGFloat smallTipsFontSize = 12;
static CGFloat leftSpace = 37;

static CGFloat imgWidth = 750;
static CGFloat imgHeight;


@implementation BYIdcardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"身份信息";
    
    self.navigationController.navigationBarHidden = NO;
    _idcardService = [[BYIdcardService alloc] init];
    
    [self setupLeftBackItem];
    [self setupUI];
    [self setViewAction];
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
    _nameTextField.placeholder = @"请输入您的姓名";
    _nameTextField.backgroundColor = BYColorWhite;
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTextField.layer.cornerRadius = 5;
    _nameTextField.layer.masksToBounds = YES;
    _nameTextField.layer.borderWidth = 1;
    _nameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // text向右偏移
    _nameTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    _nameTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_nameTextField];

    
    CGFloat numLabel_y = _nameTextField.bottom + 12;
    _codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, numLabel_y, 200, label_h)];
    _codeLabel.text = @"身份证号";
    _codeLabel.textColor = BYColor333;
    _codeLabel.font = [UIFont systemFontOfSize:bigTipsFontSize];
    [self.view addSubview:_codeLabel];

    
    CGFloat numTxf_y = _codeLabel.bottom + 12;
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftSpace, numTxf_y, textField_w, textField_h)];
    _codeTextField.placeholder = @"请输入您的身份证号";
    _codeTextField.backgroundColor = BYColorWhite;
    _codeTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _codeTextField.layer.cornerRadius = 5;
    _codeTextField.layer.masksToBounds = YES;
    _codeTextField.layer.borderWidth = 1;
    _codeTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _codeTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    _codeTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_codeTextField];

    
    CGFloat uploadBtn_w = 100;
    CGFloat uploadBtn_x = _nameTextField.right - uploadBtn_w;
    CGFloat uploadBtn_y = _codeTextField.bottom + 12;
    _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadButton.frame = CGRectMake(uploadBtn_x, uploadBtn_y, uploadBtn_w, 40);
    [_uploadButton setBackgroundImage:[[UIImage imageNamed:@"btn_red"] resizableImage] forState:UIControlStateNormal];
    [_uploadButton setBackgroundImage:[[UIImage imageNamed:@"btn_red_on"] resizableImage] forState:UIControlStateHighlighted];
    [_uploadButton setTitle:@"选择照片" forState:UIControlStateNormal];
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
    _imgView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.clipsToBounds = YES;
    _imgView.image = [UIImage imageNamed:@"img_idcard"];
    [self.view addSubview:_imgView];
    
    
    CGFloat proLabel_y = _imgView.bottom + 10;
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace - 6, proLabel_y, 8, label_h)];
    _promptLabel.text = @"*";
    _promptLabel.font = [UIFont systemFontOfSize:smallTipsFontSize];
    _promptLabel.textColor = BYColorFF4C4C;
    [self.view addSubview:_promptLabel];
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, proLabel_y, textField_w, label_h * 2)];
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.text = @"请务必上传与所填写姓名、身份证号一致的身份证正面照片，且身份证上的信息清晰可见";
    _tipsLabel.font = [UIFont systemFontOfSize:smallTipsFontSize];
    _tipsLabel.textColor = BYColor666;
    [self.view addSubview:_tipsLabel];
    
    
    CGFloat ensuerBtn_y = _tipsLabel.bottom + 12;
    _ensureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _ensureButton.frame = CGRectMake(leftSpace, ensuerBtn_y, textField_w, 40);
    [_ensureButton setBackgroundImage:[[UIImage imageNamed:@"btn_red"] resizableImage] forState:UIControlStateNormal];
    [_ensureButton setBackgroundImage:[[UIImage imageNamed:@"btn_red_on"] resizableImage] forState:UIControlStateHighlighted];
    [_ensureButton setTitle:@"确定" forState:UIControlStateNormal];
    _ensureButton.layer.cornerRadius = 5;
    _ensureButton.layer.masksToBounds = YES;
    [_ensureButton addTarget:self
                      action:@selector(ensureBtnAction:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _ensureButton];
}

- (void)setupLeftBackItem {
    UIButton* backBtn = [UIButton buttonWithNormalIconName:@"btn_nav_back" hlIconName:@"btn_nav_back"];
    [backBtn addTarget:self
                action:@selector(backBtnAction:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)backBtnAction:(UIButton *)backBtn {
    for (id vc in self.navigationController.viewControllers) {
        if ([vc isMemberOfClass:[BYNextWebVC class]]) {
            [self.navigationController popToViewController:vc animated:NO];
        }
    }
}

- (void)setViewAction {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapGestureAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture {
    [self.view becomeFirstResponder];
    [self.view endEditing:YES];
}


#pragma mark - 选择照片
- (void)selectIdcardImg:(UIButton *)uploadBtn {
    BYLog(@"选择身份证");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
//
//    UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
//    
//    /*
//     UIImagePickerControllerSourceTypePhotoLibrary, 显示所有文件夹
//     UIImagePickerControllerSourceTypeCamera,   调用系统摄像头
//     UIImagePickerControllerSourceTypeSavedPhotosAlbum 显示内置文件夹
//     */
//    pickVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    pickVC.delegate = self;
//    [self presentViewController:pickVC animated:YES completion:nil];
}

- (BOOL) isPhotoLibraryAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (UIImage *)editedImage:(UIImage *)img {
    UIImage *lastImg;
    if (img.size.width> imgWidth && img.size.height > imgWidth) {
        lastImg = [img image:img byScalingToSize:CGSizeMake(imgWidth, imgWidth)];
        return lastImg;
    } else if(img.size.width > imgWidth){
        lastImg = [img image:img byScalingToSize:CGSizeMake(imgWidth, img.size.height)];
        return lastImg;
    }else{
        lastImg = [img image:img byScalingToSize:CGSizeMake(img.size.width, imgWidth)];
        return lastImg;
    }
}



#pragma mark <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [MBProgressHUD topShowTmpMessage:@"头像上传中"];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    imgHeight = imgWidth * 0.6;
    if (img.size.width > imgWidth || img.size.height > imgHeight) {
        img = [self editedImage:img];
    }else{
    }
    
    NSData *imgFile = UIImagePNGRepresentation(img);
    [picker dismissViewControllerAnimated:YES completion:^{
        BYLog(@"图片上传中");
        [_idcardService uploadIdcardImg:imgFile finsh:^(NSDictionary *data, BYError *error) {
            if (!error) {
                BYLog(@"上传成功");
                BYLog(@"%@", data);
//                self.imgView.image = img;
//                [self.imgView setImage:img];
                UIImage *myimg = [info objectForKey:UIImagePickerControllerOriginalImage];

                [self.imgView setImage:myimg];
                _identityUrl = data[@"url"];
                [MBProgressHUD topShowTmpMessage:@"身份证图片上传成功"];
            }else {
                BYLog(@"上传失败");
            }
        }];
    }];

    
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    if ([mediaType isEqualToString:@"public.image"]) {
//        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
//        self.imgView.image = img;
//    }
//    NSData *imgFile;
//    if (UIImagePNGRepresentation(self.imgView.image)) {
//        imgFile = UIImagePNGRepresentation(self.imgView.image);
//    }else {
//        imgFile = UIImageJPEGRepresentation(self.imgView.image, 1.0);
//        if (imgFile.length > 1000 * 1000) {
//            CGFloat compressionQuality = 500 * 1000 / imgFile.length;
//            imgFile = UIImageJPEGRepresentation(self.imgView.image, compressionQuality);
//        }
//    }
//
//    [picker dismissViewControllerAnimated:YES completion:^{
//        BYLog(@"图片上传中");
//        [_idcardService uploadIdcardImg:imgFile finsh:^(NSDictionary *data, BYError *error) {
//            if (!error) {
//                BYLog(@"上传成功");
//                BYLog(@"%@", data);
//                _identityUrl = data[@"url"];
//            }else {
//                BYLog(@"上传失败");
//            }
//        }];
//    }];
}


#pragma mark - 确定信息 以及 判断
- (void)ensureBtnAction:(UIButton *)ensuerBtn {
    
    if (![self ensuerInfoCorrect]) {
        return;
    }
    
    BYIdcardVC *wself = self;
    
    NSString *userId = [NSString stringWithFormat:@"%d", [BYAppCenter sharedAppCenter].user.userID];
    [_idcardService uploadIdcardPutCasherInfoWithUserId:userId
                                                   name:_nameTextField.text
                                                   code:_codeTextField.text
                                            identityUrl:_identityUrl
                                                  finsh:^(NSDictionary *data, BYError *error) {
                                                      if ([data[@"code"] integerValue] == 1) {
                                                          BYLog(@"身份证信息上传成功--data:%@", data);
                                                          [MBProgressHUD topShowTmpMessage:@"提交信息成功"];
                                                          for (id vc in wself.navigationController.viewControllers) {
                                                              if ([vc isMemberOfClass:[BYNextWebVC class]]) {
                                                                  [wself.navigationController popToViewController:vc animated:NO];
                                                              }
                                                          }
                                                          
                                                      }else {
                                                          BYLog(@"身份证信息上传失败--error:%@", error);
                                                          [MBProgressHUD topShowTmpMessage:@"提交信息失败"];
                                                      }
                                                  }];
}


- (BOOL)ensuerInfoCorrect {
    if (![self idcardNameCorrect]) {
        [_nameTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self idcardCodeCorrect]) {
        [_codeTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self idcardImgCorrect]) {
        return NO;
    }

    return YES;
}


- (BOOL)idcardNameCorrect {
    if (_nameTextField.text.length == 0) {
        [MBProgressHUD topShowTmpMessage:@"请填写姓名"];
        return NO;
    }
    
    //  ^[\u4E00-\u9FA5]*$
    NSString *regexName = @"^\\s*[\\u4e00-\\u9fa5]{1,}[\\u4e00-\\u9fa5.·]{0,15}[\\u4e00-\u9fa5]{1,}\\s*$";
    if (![_nameTextField.text isMatchedByRegex:regexName]) {
        [MBProgressHUD topShowTmpMessage:@"姓名填写错误"];
        return NO;
    }

    return YES;
}

- (BOOL)idcardCodeCorrect {
    if (_codeTextField.text.length == 0) {
        [MBProgressHUD topShowTmpMessage:@"请填写身份证号码"];
        return NO;
    }
    
    NSString *regexIdcard = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    if (![_codeTextField.text isMatchedByRegex:regexIdcard]) {
        [MBProgressHUD topShowTmpMessage:@"身份证号填写错误"];
        return NO;
    }

    return YES;
}

- (BOOL)idcardImgCorrect {
    if (self.imgView.image == nil) {
        [MBProgressHUD topShowTmpMessage:@"请选择身份证照片"];
        return NO;
    }
    
    if (_identityUrl.length == 0) {
        [MBProgressHUD topShowTmpMessage:@"身份证照片上传失败，重新选择"];
        return NO;
    }

    return YES;
}


@end







