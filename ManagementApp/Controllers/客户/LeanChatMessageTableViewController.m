//
//  LeanChatMessageTableViewController.m
//  MessageDisplayKitLeanchatExample
//
//  Created by Jack_iMac on 15/3/21.
//  Copyright (c) 2015年 iOS软件开发工程师 曾宪华 热衷于简洁的UI QQ:543413507 http://www.pailixiu.com/blog   http://www.pailixiu.com/Jack/personal. All rights reserved.
//

#import "LeanChatMessageTableViewController.h"

#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import <AVOSCloudIM/AVOSCloudIM.h>

// IM
#import "LeanChatManager.h"

@interface LeanChatMessageTableViewController ()

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;

@property (nonatomic, strong) AVIMConversation *conversation;

@property (nonatomic, strong) NSArray *clientIDs;

@end

@implementation LeanChatMessageTableViewController

- (instancetype)initWithClientIDs:(NSArray *)clientIDs {
    self = [super init];
    if (self) {
        self.clientIDs = clientIDs;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //title
    [self.navBarView setTitle:self.clientModel.clientName image:nil];
    
    // 设置自身用户名
    self.messageSender = [self displayNameByClientId:[[LeanChatManager manager] selfClientID]];

    // 创建一个对话
    self.loadingMoreMessage = YES;
    WEAKSELF
    [[LeanChatManager manager] createConversationsWithClientIDs:self.clientIDs conversationType:0 completion:^(BOOL succeeded, AVIMConversation *createConversation) {
        if (succeeded) {
            weakSelf.conversation = createConversation;
            [weakSelf.conversation queryMessagesWithLimit:kOnePageSize callback:^(NSArray *queryMessages, NSError *error) {
                if (queryMessages.count<kOnePageSize) {
                    weakSelf.isCanLoadingMore = NO;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSMutableArray *typedMessages = [weakSelf filterTypedMessage:queryMessages];
                    NSMutableArray *messages = [NSMutableArray array];
                    for (AVIMTypedMessage *typedMessage in typedMessages) {
                        XHMessage *message = [weakSelf displayMessageByAVIMTypedMessage:typedMessage];
                        if (message) {
                            [messages addObject:message];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.messages = messages;
                        [weakSelf.messageTableView reloadData];
                        [weakSelf scrollToBottomAnimated:NO];
                        weakSelf.messageTableView.tableHeaderView = nil;
                        //延迟，以避免上面的滚动触发上拉加载消息
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            weakSelf.loadingMoreMessage = NO;
                        });
                    });
                });
            }];
        }
    }];
}

// 这里也要把 setupDidReceiveTypedMessageCompletion 放到 viewDidAppear 中
// 不然, 就会冲突, 导致不能实时接收到对方的消息
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    WEAKSELF
    [[LeanChatManager manager] setupDidReceiveTypedMessageCompletion:^(AVIMConversation *conversation, AVIMTypedMessage *message) {
        // 富文本信息
        if([conversation.conversationId isEqualToString:self.conversation.conversationId]){
            [weakSelf insertAVIMTypedMessage:message];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[LeanChatManager manager] setupDidReceiveTypedMessageCompletion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[LeanChatManager manager] setupDidReceiveTypedMessageCompletion:nil];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - LearnChat Message Handle Method

- (NSMutableArray *)filterTypedMessage:(NSArray *)messages {
    NSMutableArray *typedMessages = [NSMutableArray array];
    for (AVIMMessage *message in messages) {
        if ([message isKindOfClass:[AVIMTypedMessage class]]) {
            [typedMessages addObject:message];
        }
    }
    return typedMessages;
}

- (NSString *)fetchDataOfMessageFile:(AVFile *)file fileName:(NSString*)fileName error:(NSError**)error{
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:fileName];
    NSData *data = [file getData:error];
    if(*error == nil) {
        [data writeToFile:path atomically:YES];
    }
    return path;
}

- (XHMessage *)displayMessageByAVIMTypedMessage:(AVIMTypedMessage*)typedMessage {
    AVIMMessageMediaType msgType = typedMessage.mediaType;
    XHMessage *message;
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:typedMessage.sendTimestamp/1000];
    NSString *displayName = [self displayNameByClientId:typedMessage.clientId];
    switch (msgType) {
        case kAVIMMessageMediaTypeText: {
            AVIMTextMessage *receiveTextMessage = (AVIMTextMessage *)typedMessage;
            message = [[XHMessage alloc] initWithText:receiveTextMessage.text sender:displayName timestamp:timestamp];
            break;
        }
        case kAVIMMessageMediaTypeImage: {
            AVIMImageMessage *imageMessage = (AVIMImageMessage *)typedMessage;
            message = [[XHMessage alloc] initWithPhoto:nil thumbnailUrl:imageMessage.file.url originPhotoUrl:nil sender:displayName timestamp:timestamp];
            break;
        }
        case kAVIMMessageMediaTypeAudio: {
            NSError *error;
            NSString *path = [self fetchDataOfMessageFile:typedMessage.file fileName:typedMessage.messageId error:&error];
            AVIMAudioMessage* audioMessage = (AVIMAudioMessage *)typedMessage;
            message = [[XHMessage alloc] initWithVoicePath:path voiceUrl:nil voiceDuration:[NSString stringWithFormat:@"%.1f",audioMessage.duration] sender:displayName timestamp:timestamp];
            break;
        }
        case kAVIMMessageMediaTypeVideo: {
            AVIMVideoMessage *receiveVideoMessage=(AVIMVideoMessage*)typedMessage;
            NSString *format = receiveVideoMessage.format;
            NSError *error;
            NSString *path = [self fetchDataOfMessageFile:typedMessage.file fileName:[NSString stringWithFormat:@"%@.%@",typedMessage.messageId,format] error:&error];
            message = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:path] videoPath:path videoUrl:nil sender:displayName timestamp:timestamp];
            break;
        }
        default:
            break;
    }

    if ([typedMessage.clientId isEqualToString:[LeanChatManager manager].selfClientID]) {
        message.bubbleMessageType = XHBubbleMessageTypeSending;
         message.avatarUrl = [self avatarUrlByClientId:typedMessage.clientId];
    } else {
        message.bubbleMessageType = XHBubbleMessageTypeReceiving;
        message.avatar = [Utility getImgWithImageName:@"completeInfo_nick@2x"];
    }
    return message;
}

- (void)insertAVIMTypedMessage:(AVIMTypedMessage *)typedMessage {
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        XHMessage *message=[self displayMessageByAVIMTypedMessage:typedMessage];
        [weakSelf addMessage:message];
    });
}

- (BOOL)filterError:(NSError*)error {
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                initWithTitle:nil message:error.description delegate:nil
                                cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark - user info
/**
 * 配置头像
 */
- (NSString*)avatarUrlByClientId:(NSString*)clientId{
    AVFile *attachment = [[AVUser currentUser] objectForKey:@"header"];
    return [attachment getThumbnailURLWithScaleToFit:true width:70 height:70];
}

/**
 * 配置用户名
 */
- (NSString*)displayNameByClientId:(NSString*)clientId{
    return clientId;
}

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            break;
        case XHBubbleMessageMediaTypeVoice:
            break;
        case XHBubbleMessageMediaTypeEmotion:
            break;
        case XHBubbleMessageMediaTypeLocalPosition:
            break;
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatarOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    //点击头像
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
}


#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

- (void)loadMoreMessagesScrollTotop {
    if (self.messages.count == 0) {
        return;
    } else {
        if (!self.loadingMoreMessage) {
            self.loadingMoreMessage = YES;
            XHMessage *message = self.messages[0];
            WEAKSELF
            [self.conversation queryMessagesBeforeId:nil timestamp:[message.timestamp timeIntervalSince1970]*1000 limit:kOnePageSize callback:^(NSArray *queryMessages, NSError *error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSMutableArray *messages = [NSMutableArray array];
                    NSMutableArray *typedMessages = [self filterTypedMessage:queryMessages];
                    for(AVIMTypedMessage *typedMessage in typedMessages){
                        if (weakSelf) {
                            XHMessage *message = [weakSelf displayMessageByAVIMTypedMessage:typedMessage];
                            if (message) {
                                [messages addObject:message];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf insertOldMessages:messages completion:^{
                            weakSelf.loadingMoreMessage = NO;
                        }];
                    });
                });
            }];
        }
    }
}
/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    AVIMTextMessage *sendTextMessage = [AVIMTextMessage messageWithText:text attributes:nil];
    WEAKSELF
    [self.conversation sendMessage:sendTextMessage callback:^(BOOL succeeded, NSError *error) {
        if ([weakSelf filterError:error]) {
            [weakSelf insertAVIMTypedMessage:sendTextMessage];
            [weakSelf finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
            
            AVQuery *queryquery = [AVInstallation query];
            [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
            [queryquery whereKey:@"cid" equalTo:weakSelf.clientModel.clientId];
            AVPush *push = [[AVPush alloc] init];
            [push setQuery:queryquery];
            NSDictionary *data = @{
                                   @"alert": text,
                                   @"type": @"3"
                                   };
            [push setData:data];
            [AVPush setProductionMode:YES];
            [push sendPushInBackground];
        }
    }];
}

/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIImage *image = [Utility dealImageData:photo];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"tmp.jpg"];
    NSData* photoData=UIImageJPEGRepresentation(image,1.0);
    [photoData writeToFile:filePath atomically:YES];
    AVIMImageMessage *sendPhotoMessage = [AVIMImageMessage messageWithText:nil attachedFilePath:filePath attributes:nil];
    WEAKSELF
    [self.conversation sendMessage:sendPhotoMessage callback:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if([weakSelf filterError:error]) {
            [weakSelf insertAVIMTypedMessage:sendPhotoMessage];
            [weakSelf finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
            
            AVQuery *queryquery = [AVInstallation query];
            [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
            [queryquery whereKey:@"cid" equalTo:weakSelf.clientModel.clientId];
            AVPush *push = [[AVPush alloc] init];
            [push setQuery:queryquery];
            NSDictionary *data = @{
                                   @"alert": SetTitle(@"NewMessage"),
                                   @"type": @"3"
                                   };
            [push setData:data];
            [AVPush setProductionMode:YES];
            [push sendPushInBackground];
        }
    }];
}

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row >= self.messages.count) {
        return YES;
    } else {
        XHMessage *message = [self.messages objectAtIndex:indexPath.row];
        XHMessage *previousMessage = [self.messages objectAtIndex:indexPath.row-1];
        NSInteger interval = [message.timestamp timeIntervalSinceDate:previousMessage.timestamp];
        if (interval > 60 * 3) {
            return YES;
        } else {
            return NO;
        }
    }
}

/**
 *  配置Cell的样式或者字体
 *
 *  @param cell      目标Cell
 *  @param indexPath 目标Cell所在位置IndexPath
 */
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

@end
