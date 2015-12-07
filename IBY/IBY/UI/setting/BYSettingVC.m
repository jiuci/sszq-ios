//
//  BYSettingVC.m
//  IBY
//
//  Created by St on 14-10-29.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "BYSettingVC.h"
#import "BYFeedbackVC.h"
#import "BYAboutVC.h"
#import <SDImageCache.h>

#import "BYAppService.h"

#import "BYLinearScrollView.h"

#import "BYBaseCell.h"

#import "BYTestVC1.h"

#import <TMCache.h>

#import "BYMineCell.h"

#import "BYReSetPasswordVC.h"

#import "BYUserProfileVC.h"

#import "BYAutosizeBgButton.h"

@interface BYSettingVC()
//for test
@property (nonatomic,strong)NSMutableString *testCmdList;
@property (nonatomic,strong)NSDate *tapTime;
@property (nonatomic,strong)UIButton *testBtnA;
@property (nonatomic,strong)UIButton *testBtnB;
@property (nonatomic,strong)BYAutosizeBgButton * loginButton;
@end

@interface BYSettingVC () {
    BYAppService* _appService;
    BYBaseCell* _logoutCell;
    UILabel* cacheLabel;
//    UILabel* pushNoti;
    UIImageView *pushNoti;
    
}
@property (nonatomic, strong) BYLinearScrollView* bodyView;
@property (nonatomic, strong) UIButton* logoutButton;
@end

@implementation BYSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";

    _appService = [[BYAppService alloc] init];
    [self setupUI];
    [self setupTestUI];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BYAppCenter sharedAppCenter] updateUidAndToken];
    _loginButton.hidden = ![BYAppCenter sharedAppCenter].isLogin;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
            pushNoti.highlighted = NO;
        }else{
            pushNoti.highlighted = YES;
        }
    }else{
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
            pushNoti.highlighted = NO;
        }else{
            pushNoti.highlighted = YES;
        }
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:app];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _testBtnA.bottom = self.view.height;
    _testBtnB.bottom = self.view.height;
}

- (void)setupUI
{
    _bodyView = makeLinearScrollView(self);
    _bodyView.autoAdjustContentSize = NO;
    _bodyView.minContentSizeHeight = SCREEN_HEIGHT - self.navigationController.navigationBar.height - 20;
    self.view.height = SCREEN_HEIGHT - self.navigationController.navigationBar.height - 20;
    [self.view addSubview:_bodyView];


//    _cacheCell = [self appendCell:@""
//                            title:@"清理缓存"
//                              top:0
//                              des:[NSString stringWithFormat:@"%.1fM", (float)[TMCache sharedCache].diskByteCount / (1024 * 1024)]
//                              sel:@selector(onRemoveCache)];
    
    if ([BYAppCenter sharedAppCenter].isLogin) {
        [self appendCell:@"icon_setting_status"
                   title:@"个人资料"
                     top:12
                     des:@""
                     sel:@selector(onUserInfo)];
        
        if ([BYAppCenter sharedAppCenter].user.userType.intValue < 5) {
            [self appendCell:@"icon_setting_password"
                       title:@"修改密码"
                         top:0
                         des:@""
                         sel:@selector(onResetPassword)];
        }
    }
    
    
    [self appendCell:@"icon_setting_suggestion"
               title:@"意见反馈"
                 top:12
                 des:@""
                 sel:@selector(onFeedback)];
    
    [self appendCell:@"icon_setting_aboutus"
               title:@"关于我们"
                 top:0
                 des:@""
                 sel:@selector(onAbout)];
    
    BYMineCell* notiCell = [self appendCell:@"icon_setting_push"
               title:@"消息推送"
                 top:12
                 des:@""
                 sel:@selector(onNotification)];
    
    pushNoti = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_messagepush_off"]
                                 highlightedImage:[UIImage imageNamed:@"btn_messagepush_on"]];
    pushNoti.contentMode = UIViewContentModeScaleAspectFit;
    [notiCell addSubview:pushNoti];
    pushNoti.frame = CGRectMake(0, 7, 50, 30);
    pushNoti.right = SCREEN_WIDTH - 20;
//    pushNoti.textAlignment = NSTextAlignmentRight;
//    pushNoti.font = [UIFont systemFontOfSize:12];
//    pushNoti.textColor = HEXCOLOR(0x666666);
    
//    switcher = [[UISwitch alloc]init];
//    [notiCell addSubview:switcher];
//    switcher.onTintColor = BYColorb768;
//    switcher.frame = CGRectMake(0, 0, 2400, 64);
//    switcher.centerY = notiCell.height / 2;
//    switcher.right = notiCell.width - 22;
//    switcher.on = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
//    [switcher addTarget:self action:@selector(onSwitchNotification:) forControlEvents:UIControlEventValueChanged];

    
    BYMineCell* cacheCell = [self appendCell:@"icon_setting_clean"
               title:@"清除缓存"
                 top:0
                 des:@""
                 sel:@selector(onRemoveCache)];
    
    cacheLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 , 0, SCREEN_WIDTH / 2 - 24 , 40)];
//    cacheLabel.text = [NSString stringWithFormat:@"%.2fMB", (float)[TMCache sharedCache].diskByteCount / (1024 * 1024)];
    NSUInteger cacheSize = 0;
    cacheSize += [SDImageCache sharedImageCache].getSize;
//    NSLog(@"%lu",(unsigned long)cacheSize);
    if (cacheSize != 0) {
        cacheSize += [NSURLCache sharedURLCache].currentDiskUsage;
    }
//    NSLog(@"%lu",(unsigned long)cacheSize);
    cacheLabel.text = [NSString stringWithFormat:@"%.2fMB", (float)cacheSize / (1024 * 1024)];
    cacheLabel.font = [UIFont systemFontOfSize:12];
    cacheLabel.textColor = HEXCOLOR(0x666666);
    cacheLabel.textAlignment = NSTextAlignmentRight;
    
    [cacheCell addSubview:cacheLabel];
    NSArray *paths1=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                        , NSUserDomainMask
                                                        , YES);
    
    
    
    _loginButton = [BYAutosizeBgButton buttonWithType:UIButtonTypeCustom];
    _loginButton.frame = CGRectMake(12, 0, SCREEN_WIDTH - 12 * 2, 40);
    _loginButton.top = cacheLabel.bottom + 40;
    [_loginButton addTarget:self action:@selector(onlogout) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton setBackgroundImage:[[UIImage imageNamed:@"bg_btn_main_default"]resizableImage] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[[UIImage imageNamed:@"bg_btn_main_default"]resizableImage] forState:UIControlStateDisabled];
    [_loginButton setBackgroundImage:[[UIImage imageNamed:@"bg_btn_main_press"]resizableImage] forState:UIControlStateHighlighted];
    _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_loginButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [_loginButton setTitleColor:HEXCOLOR(0xd9b9cd) forState:UIControlStateDisabled];
    [self.bodyView by_addSubview:_loginButton paddingTop:40];
//    [self.view addSubview:_loginButton];
//    _loginButton.enabled = NO;

    
//    [self.bodyView by_addSubview:_logoutCell paddingTop:32 paddingBottom:30];
}

//+(float)folderSizeAtPath:(NSString *)path{
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    float folderSize = 0.0;
//    if ([fileManager fileExistsAtPath:path]) {
//        NSArray *childerFiles=[fileManager subpathsAtPath:path];
//        for (NSString *fileName in childerFiles) {
//            
//            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
//            float size = [BYSettingVC fileSizeAtPath:absolutePath];
//            folderSize += size;
//            NSLog(@"%f,%@",size,fileName);
//        }
//        folderSize+=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
//        return folderSize;
//    }
//    return 0;
//}
//+(float)fileSizeAtPath:(NSString *)path{
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if([fileManager fileExistsAtPath:path]){
//        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
//        return size/1024.0/1024.0;
//    }
//    return 0;
//}
- (void)onlogout
{
    UIAlertView * alert = [UIAlertView bk_alertViewWithTitle:@"您确定要退出吗？" message:@""];
    [alert bk_addButtonWithTitle:@"确定" handler:^{
        [[BYAppCenter sharedAppCenter] logout];
//        [[BYPortalCenter sharedPortalCenter] portTo:BYPortalHome];
        BYLoginSuccessBlock successblock = ^(){
            nil;
        };
        [self presentViewController:makeLoginNavFromHome(successblock, nil) animated:NO completion:nil];
    }];
    [alert bk_setCancelButtonWithTitle:@"取消" handler:^{
    }];
    [alert show];

    
}
- (BYMineCell*)appendCell:(NSString*)icon title:(NSString*)title top:(CGFloat)top des:(NSString*)des sel:(SEL)selecor
{
    BYMineCell* cell = [BYMineCell cellWithTitle:title icon:icon target:self sel:selecor];
    //    BYTitleCell* cell = [BYTitleCell controlWithKey:title value:des];
    //    cell.frame = BYRectMake(0, 0, SCREEN_WIDTH, 44);
    cell.showBottomLine = YES;
    cell.showRightArrow = NO;
    [cell addTarget:self action:selecor forControlEvents:UIControlEventTouchUpInside];
    [self.bodyView by_addSubview:cell paddingTop:top];
    return cell;
}

#pragma mark -
- (void)onUserInfo
{
    BYUserProfileVC* feedBackVC = [[BYUserProfileVC alloc] init];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

- (void)onResetPassword
{
    BYReSetPasswordVC* feedBackVC = [[BYReSetPasswordVC alloc] init];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

- (void)onRemoveCache
{
//    [[TMCache sharedCache] removeAllObjects:^(TMCache* cache) {
//        runOnMainQueue(^{
//            cacheLabel.text = [NSString stringWithFormat:@"%.2fMB", (float)[TMCache sharedCache].diskByteCount / (1024 * 1024)];
//            [MBProgressHUD topShowTmpMessage:@"清除完成"];
//        });
//    }];
    [MBProgressHUD topShow:@"清除中..."];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        runOnMainQueue(^{
            cacheLabel.text = [NSString stringWithFormat:@"%.2fMB", 0.0];
            [MBProgressHUD topShowTmpMessage:@"清除完成"];
            [[SDImageCache sharedImageCache] cleanDisk];
            [[SDImageCache sharedImageCache] clearMemory];
        });
    }];
    
}

- (void)onNotification
{
    UIAlertView * alert = [UIAlertView bk_alertViewWithTitle:@"" message:@"开启或停用，可在设置>通知中心>顺手赚钱，手动设置"];
    [alert bk_setCancelButtonWithTitle:@"确定" handler:^{
    }];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [alert bk_addButtonWithTitle:@"去设置" handler:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
    }
    [alert show];
    
}
//- (void)registerForRemoteNotifications NS_AVAILABLE_IOS(8_0);
//
//- (void)unregisterForRemoteNotifications NS_AVAILABLE_IOS(3_0);
//- (void)onSwitchNotification:(UISwitch*)sender
//{
//    if (sender.on) {
//        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
//            [[UIApplication sharedApplication] registerForRemoteNotifications];
//        }else{
//            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
//        }
//    }else{
//        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//    }
//}

//- (void)onVersion
//{
//    [_appService checkAppNeedUpdate:^(BYVersionInfo* versionInfo, BYError* error) {
//        if (error) {
//            if (error.code == BYNetErrorNotExist) {
//                [MBProgressHUD topShowTmpMessage:@"已经是最新版本了！"];
//            }else{
//                [MBProgressHUD topShowTmpMessage:BYMSG_POOR_NETWORK];
//            }
//            
//            return ;
//        }
//        
//        if (versionInfo && versionInfo.hasNewVersion) {
//            NSString *title = [NSString stringWithFormat:@"新版本v%@",versionInfo.name];
//            UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title message:versionInfo.info];
//            
//            [alert bk_addButtonWithTitle:@"去更新" handler:^{
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionInfo.url]];
//            }];
//            [alert bk_addButtonWithTitle:@"取消" handler:^{
//            }];
//            
//            [alert show];
//        }else{
//            [MBProgressHUD topShowTmpMessage:@"已经是最新版本了！"];
//        }
//    }];
//}

- (void)onFeedback
{
    BYFeedbackVC* feedBackVC = [[BYFeedbackVC alloc] init];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

- (void)onAbout
{
    BYAboutVC* aboutUsVC = [[BYAboutVC alloc] init];
    [self.navigationController pushViewController:aboutUsVC animated:YES];
}

- (void)lognOut:(id)sender
{
    [[BYAppCenter sharedAppCenter] logout];
    [[BYPortalCenter sharedPortalCenter] portTo:BYPortalHome];
}

#pragma mark -

- (void)setupTestUI {
    _testCmdList = [NSMutableString string];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:BYRectMake(0, 0, SCREEN_WIDTH/2, 70)];
    btn1.backgroundColor = BYColorClear;
    btn1.bottom = self.view.bottom;
    btn1.tag = 1;
    [btn1 addTarget:self action:@selector(onCmdBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:BYRectMake(0, 0, SCREEN_WIDTH/2, 70)];
    btn2.backgroundColor = BYColorClear;
    btn2.bottom = self.view.bottom;
    btn2.tag = 2;
    btn2.right = self.view.width;
    [btn2 addTarget:self action:@selector(onCmdBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    _testBtnA = btn1;
    _testBtnB = btn2;
    
}

- (void)onCmdBtnClick:(UIButton*)sender{
    if (!self.tapTime) {
        //首次，需要给初始值
        self.tapTime = [NSDate date];
        [_testCmdList setString:@""];
    }
    
    if ([self.tapTime timeIntervalSinceNow] < -5) {
        //太久了，需要重置combo
        self.tapTime = [NSDate date];
        [_testCmdList setString:@""];
    }
    
    NSString *c = (sender.tag == 1) ? @"a" : @"b";
    [_testCmdList appendString:c];
    
    [self onDetector];
}

- (void)onDetector{
    BYLog(@"-------%@",_testCmdList);
    if ([_testCmdList isEqualToString:@"abaaba"]) {
        [self toTestpage:@"BYTestVC1"];
    }
}

@end
