//
//  BYEPasswordViewController.m
//  IBY
//
//  Created by coco on 14-9-11.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYPasswordSettingVC.h"
#import "BYUserService.h"

@interface BYPasswordSettingVC ()

@property (weak, nonatomic) IBOutlet UITextField* firstPwdTextField;

@end

@implementation BYPasswordSettingVC {
    BOOL _showPassword;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.firstPwdTextField becomeFirstResponder];
    self.title = @"设置新密码";
    _showPassword = YES;
}

- (IBAction)commitOnclick
{
    [self.view endEditing:YES];

    if (![self.firstPwdTextField.text isValidPassword]) {
        [MBProgressHUD topShowTmpMessage:@"密码格式有误"];
        return;
    }

    NSString* user = _passwordService.phone;
    NSString* pwd = self.firstPwdTextField.text;

    [self.passwordService modifyPasswordWithPassword:pwd phoneNum:user oldPassword:nil needOldPassword:NO finish:^(NSDictionary* data, BYError* error) {
            if(error){
                [MBProgressHUD topShowTmpMessage:@"密码设置失败"];
            }else{
                [MBProgressHUD topShow:@"恭喜您密码修改成功"];
                runBlockAfterDelay(3, ^{
                    [MBProgressHUD topHide];
                    
                    runOnMainQueue(^{
                        [[BYPortalCenter sharedPortalCenter] portTo:BYPortalHome];
                    });
                    
                    
                    runOnBackgroundQueue(^{
                        BYUserService *loginService = [[BYUserService alloc] init];
                        [loginService loginByUser:user pwd:pwd finish:^(BYUser *user, BYError *error) {
                            //TODO:在后台自动登录，不用处理失败的情况?
                        }];
                    });
                    
                });
                
            }
    }];
}

- (IBAction)refreshClick:(UIButton*)sender
{
    _showPassword = !_showPassword;
    if (_showPassword) {
        [sender setTitle:@"隐藏密码" forState:UIControlStateNormal];
        [self.firstPwdTextField setSecureTextEntry:NO];
    }
    else {
        [sender setTitle:@"显示密码" forState:UIControlStateNormal];
        [self.firstPwdTextField setSecureTextEntry:YES];
    }
    //
    [self.firstPwdTextField becomeFirstResponder];
    self.firstPwdTextField.text = self.firstPwdTextField.text;
}

@end