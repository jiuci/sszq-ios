//
//  BYRegist3VC.m
//  IBY
//
//  Created by panshiyu on 15/1/4.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYRegist3VC.h"
#import "BYRegistService.h"
#import "BYLoginVC.h"
#import "BYLoginService.h"
#import "BYAutosizeBgButton.h"

#import "BYRegistSucWebVC.h"
#import "BYHomeVC.h"
#import "BYAppDelegate.h"

@interface BYRegist3VC ()
@property (weak, nonatomic) IBOutlet UITextField* firstPwdTextField;
@property (weak, nonatomic) IBOutlet UIImageView* bgInput;
@property (weak, nonatomic) IBOutlet UIImageView* iconInputLeftView;
@property (weak, nonatomic) IBOutlet BYAutosizeBgButton* btnNext;

@property (nonatomic, strong) UIButton *testBtn;

@end

@implementation BYRegist3VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置密码";

    //_registService = [[BYRegistService alloc] init];
    [self.firstPwdTextField setBk_didBeginEditingBlock:^(UITextField* txtField) {
        self.iconInputLeftView.highlighted = YES;
        self.bgInput.highlighted = YES;
    }];
    
    [self.firstPwdTextField setBk_didEndEditingBlock:^(UITextField* txtField) {
        self.iconInputLeftView.highlighted = NO;
        self.bgInput.highlighted = NO;
    }];
    [self.firstPwdTextField setBk_shouldChangeCharactersInRangeWithReplacementStringBlock:^BOOL(UITextField* txtField, NSRange range, NSString* str) {
        NSString* realStr = [txtField.text stringByReplacingCharactersInRange:range withString:str];
        if (realStr.length > 32) {
            return NO;
        }
        self.btnNext.enabled = realStr&&[realStr length]>0;
        return YES;
    }];
    [self.firstPwdTextField setBk_shouldClearBlock:^BOOL(UITextField* txtField){
        self.btnNext.enabled = NO;
        return YES;
    }];
    self.autoHideKeyboard = YES;
    self.btnNext.enabled = NO;
    
    [self setupTestBtn];
}

- (void)setupTestBtn {
//    _testBtn = [UIButton buttonWith]
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.firstPwdTextField becomeFirstResponder];
}
- (IBAction)commitOnclick
{
    [self.view endEditing:YES];
    if (self.firstPwdTextField.text.length<6) {
        [MBProgressHUD topShowTmpMessage:@"密码不能小于6位字符"];
        [self.firstPwdTextField becomeFirstResponder];
        return;
    }
    if (![self.firstPwdTextField.text isValidPassword]) {
        [MBProgressHUD topShowTmpMessage:@"密码格式错误，请重新输入"];
        [self.firstPwdTextField becomeFirstResponder];
        return;
    }
    NSString* user = _registService.phone;
    NSString* pwd = self.firstPwdTextField.text;
//    NSString* smsCode = self.registService.verifyCode;
    [MBProgressHUD topShow:@"注册中..."];
    [self.registService registByUser:user pwd:pwd finsh:^(BOOL success, BYError* error) {
//        [MBProgressHUD topHide];
        
        if (success) {
            BYHomeVC* homeVC = ((BYAppDelegate*)[UIApplication sharedApplication].delegate).homeVC;
            BYRegistSucWebVC *registSucWebVC = [[BYRegistSucWebVC alloc] init];
            [homeVC presentViewController:registSucWebVC animated:YES completion:nil];
        }

        
        if(error){
            alertError(error);
        }else{
            
                runOnMainQueue(^{
                    BYLoginService *loginService = [[BYLoginService alloc] init];
                    BYLoginVC * bylogin = [BYLoginVC sharedLoginVC];
                    bylogin.showThirdPartyLogin = YES;
                    [loginService loginByUser:user pwd:pwd finish:^(BYUser *user, BYError *error) {
                        //TODO:在后台自动登录，不用处理失败的情况?
                        if (!error) {
                            BYLoginVC * bylogin = [BYLoginVC sharedLoginVC];
                            [MBProgressHUD topHide];
                            if (bylogin.successBlk) {
                                bylogin.successBlk();
                            }
                            [self.navigationController
                             dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
                        }else{
                            [self.navigationController popToViewController:bylogin animated:YES];
                                [MBProgressHUD topHide];
                                [MBProgressHUD topShowTmpMessage:@"登录失败!请重新登录"];
                            }
                    }];
                });
        }
        
    }];
}

- (IBAction)refreshClick:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.firstPwdTextField setSecureTextEntry:NO];
    }
    else {
        [self.firstPwdTextField setSecureTextEntry:YES];
    }
    [self.view endEditing:YES];
//    [self.firstPwdTextField becomeFirstResponder];
//    self.firstPwdTextField.text = self.firstPwdTextField.text;
}

@end
