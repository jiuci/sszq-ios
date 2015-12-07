//
//  BYIMViewController.m
//  IBY
//
//  Created by forbertl on 15/9/28.
//  Copyright © 2015年 com.biyao. All rights reserved.
//

#import "BYIMViewController.h"
#import <EaseMobSDK/EaseMob.h>
#import <TPKeyboardAvoidingScrollView.h>
#import "ConvertToCommonEmoticonsHelper.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "MessageModelManager.h"
#import "NSDate+Category.h"
#import "MessageReadManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
//#import "MJRefresh.h"
#import "BYIMService.h"

#define KPageCount 20
//#import "ChatSendHelper.m"

@interface BYIMViewController ()<UITableViewDataSource,UITableViewDelegate,IEMChatProgressDelegate,EMChatManagerChatDelegate,EMChatManagerDelegate,EMCallManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>
@property (nonatomic)UIScrollView * bodyView;
@property (nonatomic)UITableView * textTable;
@property (nonatomic)UITextView * inputTextField;
@property (nonatomic)UIView * inputArea;
@property (nonatomic)UIImageView * inputAreaBg ;
@property (nonatomic)UIImageView * inputBg;
@property (nonatomic)UIButton * picture;

@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic)BOOL keyboardWasShown;
@property (nonatomic)NSDate * chatTagDate;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL needScrollToEnd;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) MessageReadManager *messageReadManager;
@property (strong, nonatomic) EMConversation *conversation;
@property (strong, nonatomic) BYIMService * service;
@property (assign, nonatomic) NSInteger lineNum;
@property (nonatomic) dispatch_queue_t messageQueue;
@property (nonatomic,assign)float inputAreaHeight;

@end

@implementation BYIMViewController


- (void)loadView
{
    UIScrollView* scroll = [[UIScrollView alloc] init ];//WithFrame:[UIScreen mainScreen].bounds];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scroll.directionalLockEnabled = YES;
    scroll.scrollEnabled = NO;
    self.navigationController.navigationBarHidden = NO;
    self.view = scroll;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lineNum = 0;
    self.title = @"客户支持";
    self.inputAreaHeight = 60;
    
    //    EMError *error = nil;
    //    for (int i = 0; i<10; i++) {
    //        NSString * username = [NSString stringWithFormat:@"iOS%d",i];
    //        NSString * psw = [NSString stringWithFormat:@"%d%d%d%d%d%d",i,i,i,i,i,i];
    //        [[EaseMob sharedInstance].chatManager registerNewAccount:username password:psw error:&error];
    //        if (!error) {
    //            NSLog(@"注册成功 %@",username);
    //        }else{
    //            NSLog(@"error :%@",error);
    //        }
    //    }
    
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    self.autoHideKeyboard = YES;
    _service = [[BYIMService alloc]init];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    //    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
    _bodyView = (UIScrollView*)self.view;
    __weak UIScrollView* blockbody = _bodyView;
    //    self.pwdTextField.bk_shouldReturnBlock = ^(UITextField* textField) {
    //        [bself onLogin];
    //        return YES;
    //    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    
    
    [self setupUI];
    
    // Do any additional setup after loading the view.
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}
- (void)setupUI
{
    float offset = 8;
    _needScrollToEnd = YES;
    _inputArea = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 20 - 44 - self.inputAreaHeight, SCREEN_WIDTH, self.inputAreaHeight)];
    _inputAreaBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _inputArea.width, _inputArea.height)];
    [_inputArea addSubview:_inputAreaBg];
    
    _inputAreaBg.image = [[UIImage imageNamed:@"bg_im_input"] resizableImage];
    
    [self.view addSubview:_inputArea];
    
    
    _inputBg = [[UIImageView alloc]initWithFrame:CGRectMake(55, offset, SCREEN_WIDTH - 55 -10, self.inputAreaHeight - offset * 2+4)];
    [_inputArea addSubview:_inputBg];
    _inputBg.image = [[UIImage imageNamed:@"bg_im_input"] resizableImage];
    
    
    _inputTextField = [[UITextView alloc]initWithFrame:CGRectMake(55 + 8, offset+2, _inputBg.width - 10 ,self.inputAreaHeight - offset * 2)];
    //    _inputTextField.backgroundColor = BYColorWhite;
    _inputTextField.font = Font(18);
    //_inputTextField.placeholder = @"输入聊天内容";
    
    [_inputArea addSubview:_inputTextField];
    _inputTextField.returnKeyType = UIReturnKeySend;
    _inputTextField.enablesReturnKeyAutomatically = YES;
    //_inputTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _inputTextField.delegate = self;
    
    
    //    __weak typeof (self) wself = self;
    //    [_inputTextField setBk_shouldReturnBlock:^BOOL(UITextField * textfield){
    //        [wself sendMessage];
    //        return YES;
    //    }];
    
    _picture = [UIButton buttonWithType:UIButtonTypeCustom];
    _picture.frame = CGRectMake(13 , (self.inputAreaHeight - 28)/2, 28, 28);
    [_inputArea addSubview:_picture];
    //    picture.backgroundColor = [UIColor blackColor];
    //    [picture setBackgroundImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>]
    [_picture setBackgroundImage:[UIImage imageNamed:@"btn_im_addpic"] forState:UIControlStateNormal];
    [_picture addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
    
    //    UIButton * emoji = [UIButton buttonWithType:UIButtonTypeCustom];
    //    emoji.frame = CGRectMake(_inputTextField.right + 10, 10, 60, 60);
    //    [_inputArea addSubview:emoji];
    //    emoji.backgroundColor = BYColor333;
    //    emoji.titleLabel.text = @"emoji";
    //
    //    [emoji addTarget:self action:@selector(sendEmoji) forControlEvents:UIControlEventTouchUpInside];
    
    _textTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH  , SCREEN_HEIGHT - 44 - 20 - self.inputAreaHeight)];
    _textTable.delegate = self;
    _textTable.dataSource = self;
    _textTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_textTable];
//    [self.textTable addHeaderWithTarget:self action:@selector(headerRereshing)];
    _textTable.backgroundColor = BYColorBG;
    
    _dataSource = [NSMutableArray array];
    _messages = [NSMutableArray array];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        //在这里做你响应return键的代码
        [_inputTextField resignFirstResponder];
        [self sendMessage];
        
        [self textViewDidChange:textView];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    float offset = 8;
    
    float height = textView.contentSize.height > 40 ? textView.contentSize.height - 40+2 : 0;
    if (textView.contentSize.height < 40) {
        _textTable.frame = CGRectMake(0, 0, SCREEN_WIDTH  , SCREEN_HEIGHT - 44 - 20 - self.inputAreaHeight);
        
        
        _inputArea.frame = CGRectMake(0, SCREEN_HEIGHT - 20 - 44 - self.inputAreaHeight, SCREEN_WIDTH, self.inputAreaHeight);
        
        _inputAreaBg.frame = CGRectMake(0, 0, _inputArea.width, _inputArea.height);
        
        _inputAreaBg.image = [[UIImage imageNamed:@"bg_im_input"] resizableImage];
        
        _inputBg.frame = CGRectMake(55, offset, SCREEN_WIDTH - 55 -10, self.inputAreaHeight - offset * 2+4);
        _inputBg.image = [[UIImage imageNamed:@"bg_im_input"] resizableImage];
        
        _inputTextField.frame = CGRectMake(55 + offset, offset+2, _inputBg.width - 10 ,self.inputAreaHeight - offset * 2);
        
        _picture.top = 16;
        
    }else if (textView.contentSize.height > 40 && textView.contentSize.height < 60) {
        _textTable.frame = CGRectMake(0,  0 , SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 20 - 60 - height);
        _inputArea.frame = CGRectMake(0,SCREEN_HEIGHT - 20 - 44 - 60-height , SCREEN_WIDTH, self.inputAreaHeight+textView.contentSize.height);
        _inputAreaBg.frame = CGRectMake(0, 0,_inputArea.width, _inputArea.height);
        _inputAreaBg.image = [[UIImage imageNamed:@"bg_im_input"] resizableImage];
//        _picture.frame = CGRectMake(13 , (_inputArea.frame.size.height - 28)/2, 28, 28);
        self.inputTextField.frame = CGRectMake(self.inputTextField.frame.origin.x, self.inputTextField.frame.origin.y, self.inputTextField.frame.size.width, textView.contentSize.height);
        _inputBg.frame = CGRectMake(55, offset, SCREEN_WIDTH - 55 -10, textView.contentSize.height+10);
        _picture.top = 16 + height;
        
    } else if(textView.contentSize.height > 60){
        
        [_inputTextField scrollRangeToVisible:NSMakeRange(_inputTextField.text.length, 1)];
        
        self.inputTextField.layoutManager.allowsNonContiguousLayout = NO;
//        _picture.top = 16 + height;
    }
}



- (void)updateUI
{
    
    if (![BYAppCenter sharedAppCenter].isLogin) {
        [self loginAction];
        return;
    }
    [MBProgressHUD topHide];
    [MBProgressHUD topShow:@"请稍候..."];
    __weak typeof (self) wself = self;
    self.title = _supplierName;
    NSString * easeMobID = [NSString stringWithFormat:@"user_%d",(unsigned int)[BYAppCenter sharedAppCenter].user.userID];

    
    [_service loadpassword:^(NSString * psw,BYError * error){
        if (error) {
            alertError(error);
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (![EaseMob sharedInstance].chatManager.isLoggedIn) {
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:easeMobID password:psw completion:^(NSDictionary *loginInfo, EMError *error) {
                if (!error && loginInfo) {
                    //                    NSLog(@"登陆成功");
                    //                    NSLog(@"%@",loginInfo);
                    [wself loadConversation];
                }
                else if ([error.description isEqualToString:@"User do not exist."]){
                    //                    NSLog(@"未注册");
                    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:easeMobID password:psw withCompletion:^(NSString * userName,NSString * passWord,EMError*error){
                        if (!error) {
                            //                        NSLog(@"注册成功 %@",easeMobID);
                            [wself updateUI];
                        }else{
                            BYLog(@"error :%@",error);
                            [MBProgressHUD topShowTmpMessage:@"登陆客服系统失败，请重试"];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } onQueue:nil];
                }
                else{
                    BYLog(@"---%@",error);
                    [MBProgressHUD topShowTmpMessage:@"登陆客服系统失败，请重试"];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            } onQueue:nil];
        }else{
            [wself loadConversation];
        }
    }];
    
    
}

- (void)easeMobLogin
{
    
}

- (void)loginAction
{
    __weak typeof (self) wself = self;
    BYLoginCancelBlock cblk = ^(){
        [[BYLoginVC sharedLoginVC] clearData];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController presentViewController:makeLoginnav(nil,cblk) animated:YES completion:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_needScrollToEnd) {
        _needScrollToEnd = YES;
    }else{
        [self updateUI];
    }
}


#pragma mark IM

- (void)loadConversation
{
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_targetUser conversationType:eConversationTypeChat];
    _conversation = conversation;
    [_conversation markAllMessagesAsRead:YES];
    [MBProgressHUD topHide];
    [_service getTargetStatus:_targetUser finish:^(BOOL status,BYError * error){
        if (!error && status) {
//            NSLog(@"online");
        }else if (!status){
            [MBProgressHUD topShowTmpMessage:@"客服不在线"];
        }else{
            [MBProgressHUD topShowTmpMessage:@"获取客服在线状态失败"];
        }
    }];
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:KPageCount append:NO];
    
}


- (void)headerRereshing
{
    _chatTagDate = nil;
    EMMessage *firstMessage = [self.messages firstObject];
    if (firstMessage)
    {
        [self loadMoreMessagesFrom:firstMessage.timestamp count:KPageCount append:YES];
    }
    [self reloadData];
//    [self.textTable headerEndRefreshing];
}

- (void)loadMoreMessagesFrom:(long long)timestamp count:(NSInteger)count append:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];
        if ([messages count] > 0) {
            NSInteger currentCount = 0;
            if (append)
            {
                [weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                NSArray *formated = [weakSelf formatMessages:messages];
                id model = [weakSelf.dataSource firstObject];
                if ([model isKindOfClass:[NSString class]])
                {
                    NSString *timestamp = model;
                    [formated enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                        if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                        {
                            [weakSelf.dataSource removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                currentCount = [weakSelf.dataSource count];
                [weakSelf.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                EMMessage *latest = [weakSelf.messages lastObject];
                weakSelf.chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)latest.timestamp];
            }
            else
            {
                weakSelf.messages = [messages mutableCopy];
                weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadData];
                if (weakSelf.dataSource.count && !append) {
//                    NSLog(@"load");
                    NSIndexPath * index = [NSIndexPath indexPathForRow:weakSelf.dataSource.count - 1 inSection:0];
                    [weakSelf.textTable scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
            });
            
            //从数据库导入时重新下载没有下载成功的附件
            //            for (EMMessage *message in messages)
            //            {
            //                [weakSelf downloadMessageAttachments:message];
            //            }
            
            NSMutableArray *unreadMessages = [NSMutableArray array];
            for (NSInteger i = 0; i < [messages count]; i++)
            {
                EMMessage *message = messages[i];
                if ([self shouldAckMessage:message read:NO])
                {
                    [unreadMessages addObject:message];
                }
            }
            if ([unreadMessages count])
            {
                [self sendHasReadResponseForMessages:unreadMessages];
            }
        }
    });
}

- (void)sendEmoji
{
    
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    }];
    [self sendImageMessage:orgImage];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)sendImageMessage:(UIImage *)image
{
    EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:image displayName:@"displayName"];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:_targetUser bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    [_service getTargetStatus:_targetUser finish:^(BOOL status,BYError * error){
        if (!error && status) {
            
        }else if (!status){
            [MBProgressHUD topShowTmpMessage:@"客服不在线"];
        }else{
            [MBProgressHUD topShowTmpMessage:@"获取客服在线状态失败"];
        }
    }];
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:self prepare:nil onQueue:nil completion:^(EMMessage * message, EMError *error){
        if (error) {
//            NSLog(@"发送失败%@",error);
//                        [MBProgressHUD topShowTmpMessage:@"消息发送失败"];
        }else{
//            NSLog(@"发送成功%@",message);
        }
    } onQueue:nil];
    _inputTextField.text = @"";
    [_messages addObject:message];
    [self reloadData];
    NSIndexPath * index = [NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0];
    [_textTable scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
    
}
#pragma mark -- end
- (void)moreViewPhotoAction
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
    // 隐藏键盘
    [self.view endEditing:YES];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    //    self.isInvisible = YES;
}
- (void)addPicture
{
    [self moreViewPhotoAction];
}

- (void)sendMessage
{
    [self.view endEditing:YES];
//    NSMutableString * inputtext = [_inputTextField.text mutableCopy];
//    if ([inputtext hasPrefix:@"change"]) {
//        [inputtext replaceCharactersInRange:NSMakeRange(0, 6) withString:@""];
//        _targetUser = inputtext;
//        _inputTextField.text = @"";
//        [self loadConversation];
//        return;
//    }
    NSString * text = [NSString stringWithString:_inputTextField.text];
    EMChatText *txtChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:_targetUser bodies:@[body]];
    message.messageType = eMessageTypeChat;
    [_service getTargetStatus:_targetUser finish:^(BOOL status,BYError * error){
        if (!error && status) {

        }else if (!status){
            [MBProgressHUD topShowTmpMessage:@"客服不在线"];
        }else{
            [MBProgressHUD topShowTmpMessage:@"获取客服在线状态失败"];
        }
    }];
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:self prepare:nil onQueue:nil completion:^(EMMessage * message, EMError *error){
        if (error) {
            BYLog(@"发送失败%@",error);
            //            [MBProgressHUD topShowTmpMessage:@"消息发送失败"];
        }else{
            BYLog(@"发送成功%@",message);
        }
    } onQueue:nil];
    _inputTextField.text = @"";
    [_messages addObject:message];
    [self reloadData];
    NSIndexPath * index = [NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0];
    [_textTable scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessage:message];
        if ([self shouldAckMessage:message read:NO])
        {
            [self sendHasReadResponseForMessages:@[message]];
        }
        if ([self shouldMarkMessageAsRead])
        {
            [self markMessagesAsRead:@[message]];
        }
    }
}
-(void)addMessage:(EMMessage *)message
{
    [_messages addObject:message];
    __weak typeof (self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.textTable reloadData];
            //            NSLog(@"add");
            [weakSelf.textTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}
- (void)markMessagesAsRead:(NSArray*)messages
{
    EMConversation *conversation = _conversation;
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [conversation markMessageWithId:message.messageId asRead:YES];
        }
    });
}

-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    model.nickName = model.username;
    model.headImageURL = [NSURL URLWithString:_supplierAvatar];
    
    if (model) {
        [ret addObject:model];
    }
    
    return ret;
}
//-(void)didReceiveMessage:(EMMessage *)message
//{
//    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
//    switch (msgBody.messageBodyType) {
//        case eMessageBodyType_Text:
//        {
//            // 收到的文字消息
//            NSString *txt = ((EMTextMessageBody *)msgBody).text;
//
//            NSLog(@"收到的文字是 txt -- %@",txt);
//        }
//            break;
//        case eMessageBodyType_Image:
//        {
//            // 得到一个图片消息body
//            EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
//            NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
//            NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
//            NSLog(@"大图的secret -- %@"    ,body.secretKey);
//            NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
//            NSLog(@"大图的下载状态 -- %lu",(unsigned long)body.attachmentDownloadStatus);
//
//
//            // 缩略图sdk会自动下载
//            NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
//            NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
//            NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
//            NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
//            NSLog(@"小图的下载状态 -- %lu",(unsigned long)body.thumbnailDownloadStatus);
//        }
//            break;
//        case eMessageBodyType_Location:
//        {
//            EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
//            NSLog(@"纬度-- %f",body.latitude);
//            NSLog(@"经度-- %f",body.longitude);
//            NSLog(@"地址-- %@",body.address);
//        }
//            break;
//        case eMessageBodyType_Voice:
//        {
//            // 音频sdk会自动下载
//            EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
//            NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
//            NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
//            NSLog(@"音频的secret -- %@"        ,body.secretKey);
//            NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
//            NSLog(@"音频文件的下载状态 -- %lu"   ,(unsigned long)body.attachmentDownloadStatus);
//            NSLog(@"音频的时间长度 -- %lu"      ,(long)body.duration);
//        }
//            break;
//        case eMessageBodyType_Video:
//        {
//            EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
//
//            NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
//            NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
//            NSLog(@"视频的secret -- %@"        ,body.secretKey);
//            NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
//            NSLog(@"视频文件的下载状态 -- %lu"   ,(unsigned long)body.attachmentDownloadStatus);
//            NSLog(@"视频的时间长度 -- %lu"      ,(long)body.duration);
//            NSLog(@"视频的W -- %f ,视频的H -- %f", body.size.width, body.size.height);
//
//            // 缩略图sdk会自动下载
//            NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
//            NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailRemotePath);
//            NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
//            NSLog(@"缩略图的下载状态 -- %lu"      ,(unsigned long)body.thumbnailDownloadStatus);
//        }
//            break;
//        case eMessageBodyType_File:
//        {
//            EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
//            NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
//            NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
//            NSLog(@"文件的secret -- %@"        ,body.secretKey);
//            NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
//            NSLog(@"文件文件的下载状态 -- %lu"   ,(unsigned long)body.attachmentDownloadStatus);
//        }
//            break;
//
//        default:
//            break;
//    }
//    [self loadConversation];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else{
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            
            return cell;
        }
    }
    
    return nil;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    }
    else{
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    NSArray * array = [messagesArray copy];
    if ([array count] > 0) {
        for (EMMessage *message in array) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            model.nickName = model.username;
            model.headImageURL = [NSURL URLWithString:_supplierAvatar];
            
            if (model) {
                [formatArray addObject:model];
            }
        }
    }
    
    return formatArray;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *message = self.dataSource[indexPath.row];
    if (message.content.length) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
    if (action == @selector(cut:) || action == @selector(paste:)) {
        return NO;
    }else{
    }
    MessageModel *message = self.dataSource[indexPath.row];
    if (message.content.length) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    MessageModel *message = self.dataSource[indexPath.row];
    if (action == @selector(copy:)) {
        if (message.content.length) {
            [UIPasteboard generalPasteboard].string = message.content;
        }
    }
}

- (void)reloadData{
    _chatTagDate = nil;
    self.dataSource = [[self formatMessages:self.messages] mutableCopy];
    [self.textTable reloadData];
    
    //回到前台时
    //    if (!self.isInvisible)
    //    {
    //        NSMutableArray *unreadMessages = [NSMutableArray array];
    //        for (EMMessage *message in self.messages)
    //        {
    //            if ([self shouldAckMessage:message read:NO])
    //            {
    //                [unreadMessages addObject:message];
    //            }
    //        }
    //        if ([unreadMessages count])
    //        {
    //            [self sendHasReadResponseForMessages:unreadMessages];
    //        }
    //
    //        [_conversation markAllMessagesAsRead:YES];
    //    }
}
- (NSDate *)chatTagDate
{
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}
- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
     forMessageBody:(id<IEMMessageBody>)messageBody
{
//    NSLog(@"%f,%@",progress,message.messageBodies);
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    //    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    [self.bodyView setContentOffset:CGPointMake(0, keyboardSize.height) animated:YES];
    _keyboardWasShown = YES;
}
- (void) keyboardWasHidden:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    //    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    [self.bodyView setContentOffset:CGPointMake(0,0) animated:YES];
    _keyboardWasShown = NO;
    
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    //    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
    //        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    //    }
    //    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
    //        [self chatAudioCellBubblePressed:model];
    //    }
    //    else
    if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    }
    //    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
    //        [self chatLocationCellBubblePressed:model];
    //    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        if ((messageModel.status != eMessageDeliveryState_Failure) && (messageModel.status != eMessageDeliveryState_Pending))
        {
            return;
        }
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
        NSIndexPath *indexPath = [self.textTable indexPathForCell:resendCell];
        [self.textTable beginUpdates];
        [self.textTable reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.textTable endUpdates];
    }
    //        else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
    //        [self chatVideoCellPressed:model];
    //    }else if ([eventName isEqualToString:kRouterEventMenuTapEventName]) {
    //        [self sendTextMessage:[userInfo objectForKey:@"text"]];
    //    }
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model
{
    __weak typeof (self) weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                //发送已读回执
                if ([self shouldAckMessage:model.message read:YES])
                {
                    [self sendHasReadResponseForMessages:@[model.message]];
                }
                NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    self.needScrollToEnd = NO;
                    if (image)
                    {
                        [self.messageReadManager showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        BYLog(@"Read %@ failed!", localPath);
                    }
                    return ;
                }
            }
            [MBProgressHUD topShow:@"加载中..."];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [MBProgressHUD topHide];
                if (!error) {
                    //发送已读回执
                    if ([weakSelf shouldAckMessage:model.message read:YES])
                    {
                        [weakSelf sendHasReadResponseForMessages:@[model.message]];
                    }
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        weakSelf.needScrollToEnd = NO;
                        if (image)
                        {
                            [weakSelf.messageReadManager showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            BYLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [MBProgressHUD topShowTmpMessage:@"加载失败"];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [MBProgressHUD topShowTmpMessage:@"加载失败"];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [MBProgressHUD topShowTmpMessage:@"加载失败"];
                }
            } onQueue:nil];
        }
    }
}

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground))// || self.isInvisible)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)shouldMarkMessageAsRead
{
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground))// || self.isInvisible)
    {
        return NO;
    }
    
    return YES;
}

- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak typeof (self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    MessageModel *model = (MessageModel *)object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.textTable beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.textTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.textTable endUpdates];
                        });
                        break;
                    }
                }
            }
        }
    });
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
