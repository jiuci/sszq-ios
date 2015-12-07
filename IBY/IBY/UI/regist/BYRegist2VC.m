//
//  BYRegist2VC.m
//  IBY
//
//  Created by panshiyu on 15/1/4.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "BYRegist2VC.h"
#import "BYRegistService.h"
#import "BYAutosizeBgButton.h"
#import "BYBaseWebVC.h"
#import "BYRegist3VC.h"

@interface BYRegist2VC ()

@property (weak, nonatomic) IBOutlet UILabel* phoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField* smsCodeTextField;
@property (weak, nonatomic) IBOutlet BYAutosizeBgButton* resendBtn;
@property (weak, nonatomic) IBOutlet UIImageView* bgInput;
@property (weak, nonatomic) IBOutlet UIImageView* iconInputLeftView;
@property (weak, nonatomic) IBOutlet UITextField* txtSMSInput;
@property (weak, nonatomic) IBOutlet BYAutosizeBgButton* btnNext;
@property (nonatomic, assign) int countdownTime;
@property (nonatomic, strong) NSTimer* smsCountTimer;
@property (nonatomic, assign) BOOL enterSMSHelper;
@end

@implementation BYRegist2VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"快速注册";

    _registService = [[BYRegistService alloc] init];
    _registService.phone = _phone;

    self.phoneNumLabel.text = [_registService.phone chineseMobileFormat];

    [self.txtSMSInput setBk_didBeginEditingBlock:^(UITextField* txtField) {
        self.iconInputLeftView.highlighted = YES;
        self.bgInput.highlighted = YES;
    }];

    [self.txtSMSInput setBk_didEndEditingBlock:^(UITextField* txtField) {
        self.iconInputLeftView.highlighted = NO;
        self.bgInput.highlighted = NO;
    }];
    [self.txtSMSInput setBk_shouldChangeCharactersInRangeWithReplacementStringBlock:^BOOL(UITextField* txtField, NSRange range, NSString* str) {
        NSString* realStr = [txtField.text stringByReplacingCharactersInRange:range withString:str];
        self.btnNext.enabled = realStr&&[realStr length]>0;
        return YES;
    }];
    [self.txtSMSInput setBk_shouldClearBlock:^BOOL(UITextField* txtField){
        self.btnNext.enabled = NO;
        return YES;
    }];
    
    self.btnNext.enabled = NO;
    _enterSMSHelper = NO;
    self.autoHideKeyboard = YES;
    [self beginTimer];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _enterSMSHelper = NO;
    [self.smsCodeTextField becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_enterSMSHelper) {
        return;
    }
    if (_smsCountTimer) {
        [_smsCountTimer invalidate];
        _smsCountTimer = nil;
    }
}

- (void)beginTimer
{
    _countdownTime = 60;
    self.resendBtn.enabled = NO;

    _smsCountTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(onTimerUpdate)
                                                    userInfo:nil
                                                     repeats:YES];
    [_smsCountTimer fire];
}

- (void)stopTimer
{
    _resendBtn.enabled = YES;
    [self.resendBtn setTitle:@"重发验证码" forState:UIControlStateNormal];
    _countdownTime = 60;
    [_smsCountTimer invalidate];
    _smsCountTimer = nil;
}

- (void)onTimerUpdate
{
    if (_countdownTime < 1) {
        [self stopTimer];
    }
    else {
        self.resendBtn.enabled = NO;
        NSString* txt = [NSString stringWithFormat:@"%d秒后重发", _countdownTime];
        [self.resendBtn setTitle:txt forState:UIControlStateDisabled];

        _countdownTime--;
    }
}
- (IBAction)onSMScodeHelper:(id)sender
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSZQURL_BASE, SSZQURL_SERVICE_SMSCODEHELPER];
    BYBaseWebVC* webVC = [[BYBaseWebVC alloc] initWithURL:[NSURL URLWithString:urlStr]];
    webVC.useWebTitle = YES;
    _enterSMSHelper = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
- (IBAction)nextStepOnclick
{
    [self.view endEditing:YES];

    self.registService.verifyCode = self.smsCodeTextField.text;
    [self.registService checkVerifyCode:self.smsCodeTextField.text
                                  phone:_registService.phone
                                 finish:^(BOOL success, BYError* error) {
                                     if (error) {
                                         alertError(error);
                                         [self.smsCodeTextField becomeFirstResponder];
                                     }
                                     else {
                                         BYRegist3VC* setPwdVC = [[BYRegist3VC alloc] init];
                                         setPwdVC.registService = self.registService;
                                         [self.navigationController pushViewController:setPwdVC animated:YES];
                                     }
                                 }];
}

- (IBAction)sendCodeAgainClick:(id)sender
{
    [self fetchSMSCode];
}

- (void)fetchSMSCode
{ //这是重发机制，不需要再处理其他类型status
    [self.registService fetchSMSVerifyCodeWithPhone:_registService.phone
                                             finish:^(BYFetchVerifyCodeStatus status, BYError* error) {
                                                 if (error) {
                                                     alertError(error);
                                                 }
                                                 else {
                                                     [self beginTimer];
                                                 }
                                             }];
}

@end
