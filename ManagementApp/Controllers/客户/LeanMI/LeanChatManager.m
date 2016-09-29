//
//  LeanChatManager.m
//  MessageDisplayKitLeanchatExample
//
//  Created by Jack_iMac on 15/3/21.
//  Copyright (c) 2015年 iOS软件开发工程师 曾宪华 热衷于简洁的UI QQ:543413507 http://www.pailixiu.com/blog   http://www.pailixiu.com/Jack/personal. All rights reserved.
//

#import "LeanChatManager.h"
#import "LeanChatCoreDataManager.h"

#define kApplicationId @"4buRKUuDv5oI11CpPtogkX6X"
#define kClientKey @"1pJLrtIay3l2wgF8PTCJCJNT"

@interface LeanChatManager () <AVIMClientDelegate>

@property (nonatomic, strong) AVIMClient *leanClient;

@property (nonatomic, copy) NSString *selfClientID;

@property (nonatomic, copy) DidReceiveCommonMessageBlock didReceiveCommonMessageCompletion;
@property (nonatomic, copy) DidReceiveTypedMessageBlock didReceiveTypedMessageCompletion;

@property (nonatomic, strong) NSMutableArray* recentConversations;

@end

@implementation LeanChatManager

+ (void)setupApplication {
    [AVOSCloud setApplicationId:kApplicationId clientKey:kClientKey];
#ifdef DEBUG
    [AVAnalytics setAnalyticsEnabled:NO];
    [AVOSCloud setVerbosePolicy:kAVVerboseShow];
    [AVLogger addLoggerDomain:AVLoggerDomainIM];
    [AVLogger addLoggerDomain:AVLoggerDomainCURL];
    [AVLogger setLoggerLevelMask:AVLoggerLevelAll];
#endif
    
    [AVIMClient setUserOptions:@{
                                 AVIMUserOptionUseUnread: @(YES)
                                 }];
}

+ (instancetype)manager {
    static LeanChatManager *leanChatManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leanChatManager = [[LeanChatManager alloc] init];
    });
    return leanChatManager;
}

- (void)setup {
    self.leanClient = [[AVIMClient alloc] init];
    self.leanClient.delegate = self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setupDidReceiveCommonMessageCompletion:(DidReceiveCommonMessageBlock)didReceiveCommonMessageCompletion {
    _didReceiveCommonMessageCompletion = nil;
    _didReceiveCommonMessageCompletion = [didReceiveCommonMessageCompletion copy];
}

- (void)setupDidReceiveTypedMessageCompletion:(DidReceiveTypedMessageBlock)didReceiveTypedMessageCompletion {
    _didReceiveTypedMessageCompletion = nil;
    _didReceiveTypedMessageCompletion = [didReceiveTypedMessageCompletion copy];
}


- (void)openSessionWithClientID:(NSString *)clientID
                     completion:(void (^)(BOOL succeeded, NSError *error))completion {
    self.selfClientID = clientID;
    if (self.leanClient.status == AVIMClientStatusNone) {
        [self.leanClient openWithClientId:clientID callback:completion];
    } else {
        [self.leanClient closeWithCallback:^(BOOL succeeded, NSError *error) {
            [self.leanClient openWithClientId:clientID callback:completion];
        }];
    }
}

- (void)createConversationsWithClientIDs:(NSArray *)clientIDs
                        conversationType:(ConversationType)conversationType
                              completion:(void (^)(BOOL succeeded, AVIMConversation *createConversation))completion {
    NSMutableArray *targetClientIDs = [[NSMutableArray alloc] initWithArray:clientIDs];
    [targetClientIDs insertObject:self.selfClientID atIndex:0];
    [self createConversationsOnClientIDs:targetClientIDs conversationType:conversationType completion:completion];
}

- (void)createConversationsOnClientIDs:(NSArray *)clientIDs
                      conversationType:(int)conversationType
                            completion:(void (^)(BOOL, AVIMConversation *))completion {
    AVIMConversationQuery *query = [self.leanClient conversationQuery];
    NSMutableArray *queryClientIDs = [[NSMutableArray alloc] initWithArray:clientIDs];
    [queryClientIDs insertObject:self.selfClientID atIndex:0];
    [query whereKey:kAVIMKeyMember containsAllObjectsInArray:queryClientIDs];
    [query whereKey:AVIMAttr(@"type") equalTo:[NSNumber numberWithInt:conversationType]];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        if (error) {
            // 出错了，请稍候重试
            if (completion) {
                completion(NO, nil);
            }
        } else if (!objects || [objects count] < 1) {
            // 新建一个对话
            [self.leanClient createConversationWithName:nil
                                              clientIds:queryClientIDs
                                             attributes:@{@"type":[NSNumber numberWithInt:conversationType]}
                                                options:AVIMConversationOptionNone
                                               callback:^(AVIMConversation *conversation, NSError *error) {
                                                   BOOL succeeded = YES;
                                                   if (error) {
                                                       succeeded = NO;
                                                   }
                                                   if (completion) {
                                                       completion(succeeded, conversation);
                                                   }
                                               }];
        } else {
            // 已经有一个对话存在，继续在这一对话中聊天
            AVIMConversation *conversation = [objects lastObject];
            if (completion) {
                completion(YES, conversation);
            }
        }
    }];
}

-(void)findRecentConversationsWithBlock:(AVIMArrayResultBlock)block{
    AVIMConversationQuery* query=[self.leanClient conversationQuery];
    [query whereKey:kAVIMKeyMember containsAllObjectsInArray:@[self.selfClientID,[AVUser currentUser].username]];
    query.limit=1000;
    [query findConversationsWithCallback:block];
}

-(void)close:(void (^)(BOOL succeeded, NSError *error))completion {
    [self.leanClient closeWithCallback:completion];
}

#pragma mark - AVIMClientDelegate

- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // 接收到新的普通消息。
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:conversation.members];
    [tempArray removeObject:[AVUser currentUser].username];
    
    if (self.messageTo && [self.messageTo isEqualToString:tempArray[0]]) {
        
    }else {
        [[LeanChatCoreDataManager manager] increaseUnreadCountByConversationId:conversation.conversationId];
        
        ///保存未读消息树目
        NSArray *allkeys = [[DataShare sharedService].unreadMessageDic allKeys];
        if (tempArray.count>0) {
            if ([allkeys containsObject:tempArray[0]]) {
                NSInteger value = [[[DataShare sharedService].unreadMessageDic objectForKey:tempArray[0]]integerValue] +1;
                [[DataShare sharedService].unreadMessageDic setObject:@(value) forKey:tempArray[0]];
            }else {
                [[DataShare sharedService].unreadMessageDic setObject:@(1) forKey:tempArray[0]];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"unreadeMessage" object:tempArray[0]];
        }
    }
    
    
    if(self.didReceiveCommonMessageCompletion){
        self.didReceiveCommonMessageCompletion(conversation,message);
    }
}

- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // 接收到新的富媒体消息。
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:conversation.members];
    [tempArray removeObject:[AVUser currentUser].username];
    
    if (self.messageTo && [self.messageTo isEqualToString:tempArray[0]]) {
        
    }else {
        [[LeanChatCoreDataManager manager] increaseUnreadCountByConversationId:conversation.conversationId];
        
        ///保存未读消息树目
        NSArray *allkeys = [[DataShare sharedService].unreadMessageDic allKeys];
        if (tempArray.count>0) {
            if ([allkeys containsObject:tempArray[0]]) {
                NSInteger value = [[[DataShare sharedService].unreadMessageDic objectForKey:tempArray[0]]integerValue] +1;
                [[DataShare sharedService].unreadMessageDic setObject:@(value) forKey:tempArray[0]];
            }else {
                [[DataShare sharedService].unreadMessageDic setObject:@(1) forKey:tempArray[0]];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"unreadeMessage" object:tempArray[0]];
        }
        
    }
    
    if(self.didReceiveTypedMessageCompletion){
        self.didReceiveTypedMessageCompletion(conversation,message);
    }
}
- (void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:conversation.members];
    [tempArray removeObject:[AVUser currentUser].username];
    
    ///保存未读消息树目
    NSArray *allkeys = [[DataShare sharedService].unreadMessageDic allKeys];
    if (tempArray.count>0) {
        if ([allkeys containsObject:tempArray[0]]) {
            NSInteger value = [[[DataShare sharedService].unreadMessageDic objectForKey:tempArray[0]]integerValue] +unread;
            [[DataShare sharedService].unreadMessageDic setObject:@(value) forKey:tempArray[0]];
        }else {
            [[DataShare sharedService].unreadMessageDic setObject:@(unread) forKey:tempArray[0]];
        }
    }
    
    [conversation markAsReadInBackground];
}
#pragma mark - Core Data With Conversation

@end
