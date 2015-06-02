//
//  BYEVerifycodeodeViewController.m
//  IBY
//
//  Created by coco on 14-9-11.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYVerifySmsCodeVC.h"
#import "BYPasswordSettingVC.h"
#import "BYPasswordService.h"
#import "BYAutosizeBgButton.h"

@interface BYVerifySmsCodeVC ()
@property (strong, nonatomic) BYPasswordService* passwordService;

@property (weak, nonatomic) IBOutlet UILabel* phoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField* smsCodeTextField;
@property (weak, nonatomic) IBOutlet BYAutosizeBgButton* resendBtn;

@property (nonatomic, assign) int countdownTime;
@property (nonatomic, strong) NSTimer* smsCountTimer;

@end

@implementation BYVerifySmsCodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _titleFromLastPage ? _titleFromLastPage : @"输入验证码";

    _passwordService = [[BYPasswordService alloc] init];
    _passwordService.phone = _phone;

    self.phoneNumLabel.text = _passwordService.phone;
    [self.smsCodeTextField becomeFirstResponder];

    self.autoHideKeyboard = YES;

    [self fetchSMSCode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

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
    [_smsCountTimer invalidate];
    _smsCountTimer = nil;
    _resendBtn.enabled = YES;
    [self.resendBtn setTitle:@"重发验证码" forState:UIControlStateNormal];
    _countdownTime = 60;
}

- (void)onTimerUpdate
{
    if (_countdownTime < 1) {
        [self stopTimer];
    }
    else {
        _countdownTime--;

        self.resendBtn.enabled = NO;
        NSString* txt = [NSString stringWithFormat:@"%d秒后重发", _countdownTime];
        [self.resendBtn setTitle:txt forState:UIControlStateDisabled];
    }
}

- (IBAction)nextStepOnclick
{
    [self.view endEditing:YES];

    [self.passwordService checkVerifyCode:self.smsCodeTextField.text phone:self.phoneNumLabel.text finish:^(NSDictionary* data, BYError* error) {
        if(error){
            [MBProgressHUD showError:@"验证码错误"];
        }else{
            BYPasswordSettingVC *setPwdVC = [[BYPasswordSettingVC alloc] init];
            setPwdVC.passwordService = self.passwordService;
            [self.navigationController pushViewController:setPwdVC animated:YES];
        }
    }];
}

- (IBAction)sendCodeAgainClick:(id)sender
{
    [self fetchSMSCode];
}

- (void)fetchSMSCode
{
    [self.passwordService fetchSMSVerifyCodeWithPhone:_passwordService.phone finish:^(NSDictionary* data, BYError* error) {
        if(error){
            [MBProgressHUD topShowTmpMessage:@"验证码发送错误"];
        }else{
            [self beginTimer];
        }
    }];
}

@end