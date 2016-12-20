//
//  LCChatKitExample.m
//  LeanCloudChatKit-iOS
//
//  v0.7.20 Created by ElonChan (微信向我报BUG:chenyilong1010) on 16/2/24.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//



#import "LCCKUser.h"
#import "LCChatKit.h"
#import "LCCKUtil.h"
#import "LCChatKitExample+Setting.h"

@implementation LCChatKitExample (Setting)

- (void)lcck_setting {
    [self lcck_setupAppInfo];
    //设置用户体系
    [self lcck_setFetchProfiles];
    //设置聊天
    [self lcck_setupConversation];
    // 其他各种设置
    [self lcck_setupOther];
}

- (void)lcck_setupConversation {
    //设置打开会话的操作
    [self lcck_setupOpenConversation];
    [self lcck_setupConversationInvalidedHandler];
    [self lcck_setupLoadLatestMessages];
}

- (void)lcck_setupOther {
    [self lcck_setupBadge];
    
    [self lcck_setupForceReconect];
//    [self lcck_setupFilterMessage];
    //发送消息HOOK
    [self lcck_setupSendMessageHook];
    //开启圆角
    [self lcck_setupAvatarImageCornerRadius];
    
//    [self lcck_setupNotification];
}
/**
 *  设置收到ChatKit的通知处理
 */
- (void)lcck_setupNotification {
    [[LCChatKit sharedInstance] setShowNotificationBlock:^(UIViewController *viewController, NSString *title,
                                                           NSString *subtitle, LCCKMessageNotificationType type) {
        [self lcck_exampleShowNotificationWithTitle:title subtitle:subtitle type:type];
    }];
}

- (void)lcck_exampleShowNotificationWithTitle:(NSString *)title
                                     subtitle:(NSString *)subtitle
                                         type:(LCCKMessageNotificationType)type {
    [LCCKUtil showNotificationWithTitle:title subtitle:subtitle type:type];
}
#pragma mark - leanCloud的app信息设置
- (void)lcck_setupAppInfo {
    [[LCChatKit sharedInstance] setDisableSingleSignOn:YES];
    [[LCChatKit sharedInstance] setUseDevPushCerticate:NO];
}

#pragma mark - 用户体系的设置
/**
 *  设置用户体系，里面要实现如何根据 userId 获取到一个 User 对象的逻辑。
 *  ChatKit 会在需要用到 User信息时调用设置的这个逻辑。
 */
- (void)lcck_setFetchProfiles {
    [[LCChatKit sharedInstance] setFetchProfilesBlock:^(NSArray<NSString *> *userIds,
                             LCCKFetchProfilesCompletionHandler completionHandler) {
         if (userIds.count == 0) {
             NSInteger code = 0;
             NSString *errorReasonText = @"User ids is nil";
             NSDictionary *errorInfo = @{
                                         @"code":@(code),
                                         NSLocalizedDescriptionKey : errorReasonText,
                                         };
             NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                  code:code
                                              userInfo:errorInfo];
             
             !completionHandler ?: completionHandler(nil, error);
             return;
         }
         
         NSMutableArray *users = [NSMutableArray arrayWithCapacity:userIds.count];

        [userIds enumerateObjectsUsingBlock:^(NSString *_Nonnull clientId, NSUInteger idx,
                                              BOOL *_Nonnull stop) {
            if ([clientId isEqualToString:[DataShare sharedService].userObject.userName]) {
                LCCKUser *user_ = [LCCKUser userWithUserId:[DataShare sharedService].userObject.userId
                                                      name:[DataShare sharedService].userObject.userName
                                                 avatarURL:[NSURL URLWithString:[DataShare sharedService].userObject.header]
                                                  clientId:clientId];
                [users addObject:user_];
            }else {
                LCCKUser *user2_ = [LCCKUser userWithUserId:[DataShare sharedService].clientObject.clientId
                                                       name:[DataShare sharedService].clientObject.clientName
                                                  avatarURL:[DataShare sharedService].clientObject.header==nil?[NSURL URLWithString:@""]:[NSURL URLWithString:[DataShare sharedService].clientObject.header]
                                                   clientId:clientId];
                [users addObject:user2_];
            }
        }];
         !completionHandler ?: completionHandler([users copy], nil);
     }];
}

#pragma mark - 签名机制设置

/*!
 * 参考 https://leancloud.cn/docs/realtime_v2.html#权限和认证
 * 需要使用同步请求
 */
//- (void)lcck_setGenerateSignature {
//    [[LCChatKit sharedInstance] setGenerateSignatureBlock:^(NSString *clientId, NSString     *conversationId, NSString *action, NSArray *clientIds, LCCKGenerateSignatureCompletionHandler completionHandler) {
//        NSMutableDictionary *paramsM = [NSMutableDictionary   dictionaryWithDictionary:@{@"token": [AccountManager sharedAccountManager].bestoneAccount.authentication_token}];
//        if (clientIds.count) {
//            [paramsM addEntriesFromDictionary:@{@"member_ids": clientIds}];
//        }
//        if (conversationId.length) {
//            [paramsM addEntriesFromDictionary:@{@"conversation_id": conversationId}];
//        }
//        if (action.length) {
//            [paramsM addEntriesFromDictionary:@{@"conv_action": action}];
//        }
//        
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//        
//        __block AVIMSignature *signature_ = nil;
//        [HTTPSolution responseObjectWithMethod:@"GET" URLString:kSignatureURLStr parameters:[paramsM copy] wantData:NO success:^(NSURLResponse *response, id responseObject) {
//            signature_ = [[AVIMSignature alloc] init];
//            signature_.signature = responseObject[@"signature"];
//            signature_.timestamp = [responseObject[@"timestamp"] longLongValue];
//            signature_.nonce = responseObject[@"nonce"];
//            !completionHandler ?: completionHandler(signature_, nil);
//            LCCKLog(@"签名请求成功。。。。");
//            dispatch_semaphore_signal(semaphore);
//        } failure:^(NSError *error) {
//            
//            signature_ = [[AVIMSignature alloc] init];
//            signature_.error = error;
//            NSLog(@"error: %@", error.localizedDescription);
//            !completionHandler ?: completionHandler(signature_, error);
//            dispatch_semaphore_signal(semaphore);
//        }];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        LCCKLog(@"我在等待信号量增加！。。。。。");
//    }];
//}

#pragma mark - 聊天页面的设置
/**
 *  打开一个会话的操作
 */
- (void)lcck_setupOpenConversation {
    [[LCChatKit sharedInstance] setFetchConversationHandler:^(
                                                              AVIMConversation *conversation,
                                                              LCCKConversationViewController *aConversationController) {

    }];
}

/**
 *  设置会话出错的回调处理
 */
- (void)lcck_setupConversationInvalidedHandler {
    [[LCChatKit sharedInstance] setConversationInvalidedHandler:^(NSString *conversationId,
                                       LCCKConversationViewController *conversationController,
                                       id<LCCKUserDelegate> administrator, NSError *error) {
         NSString *title;
         NSString *subTitle;
         //错误码参考：https://leancloud.cn/docs/realtime_v2.html#%E4%BA%91%E7%AB%AF%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
         if (error.code == 4401) {
             /**
              * 下列情景下会执行
              - 当前用户被踢出群，也会执行
              - 用户不在当前群中，且未开启 `enableAutoJoin` (自动进群)
              */
             [conversationController.navigationController popToRootViewControllerAnimated:YES];
             title = @"进群失败！";
             subTitle = [NSString stringWithFormat:@"请联系管理员%@",
                         administrator.name ?: administrator.clientId];
             LCCKLog(@"%@", error.description);
         } else if (error.code == 4304) {
             title = @"群已满";
         }
     }];
}

/**
 *  加载最近聊天记录的回调
 */
- (void)lcck_setupLoadLatestMessages {
    [[LCChatKit sharedInstance]
setLoadLatestMessagesHandler:^(LCCKConversationViewController *conversationController,
                                    BOOL succeeded, NSError *error) {
     }];
}

/**
 *  强制重连
 */
- (void)lcck_setupForceReconect {
    
    QWeakSelf(self);
    [[LCChatKit sharedInstance] setForceReconnectSessionBlock:^(
                                                                NSError *aError, BOOL granted,
                                                                __kindof UIViewController *viewController,
                                                                LCCKReconnectSessionCompletionHandler completionHandler) {
        if (granted == YES) {
            BOOL force = YES;
            [[LCChatKit sharedInstance] openWithClientId:[DataShare sharedService].userObject.userName
             force:force
             callback:^(BOOL succeeded, NSError *error) {
                 !completionHandler ?: completionHandler(succeeded, error);
             }];
            return;
        }else {
            [AVUser logOut];  //清除缓存用户对象
            [Utility dataShareClear];
            
            [weakself performSelectorOnMainThread:@selector(loadLogin) withObject:nil waitUntilDone:NO];
        }
        !completionHandler ?: completionHandler(NO, nil);
    }];
}

- (void)loadLogin {
    [[AppDelegate shareInstance]showRootVCWithType:0];
}

//筛选消息----接收消息
-(void)lcck_setupFilterMessage {
    
    [[LCChatKit sharedInstance] setFilterMessagesBlock:^(AVIMConversation *conversation, NSArray<AVIMTypedMessage *> *messages, LCCKFilterMessagesCompletionHandler completionHandler) {
        
        for (AVIMTypedMessage *typedMessage in messages) {
            LCCKMessage *message = [LCCKMessage messageWithAVIMTypedMessage:typedMessage];
            if (message) {
                
                if ([AppDelegate shareInstance].messageTo && [[AppDelegate shareInstance].messageTo isEqualToString:message.sender.clientId]) {
                }else {
                    ///保存未读消息
                    NSArray *allkeys = [[DataShare sharedService].unreadMessageDic allKeys];
                    if ([allkeys containsObject:message.sender.clientId]) {
                        NSInteger value = [[[DataShare sharedService].unreadMessageDic objectForKey:message.sender.clientId]integerValue] +1;
                        [[DataShare sharedService].unreadMessageDic setObject:@(value) forKey:message.sender.clientId];
                    }else {
                        [[DataShare sharedService].unreadMessageDic setObject:@(1) forKey:message.sender.clientId];
                    }
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"unreadeMessage" object:message.sender.clientId];
                }
            }
        }
        completionHandler(messages, nil);
    }];
}

-(void)lcck_setupSendMessageHook {
    [[LCChatKit sharedInstance] setSendMessageHookBlock:^(LCCKConversationViewController *conversationController, __kindof AVIMTypedMessage *message, LCCKSendMessageHookCompletionHandler completionHandler) {
        
        
        NSString *text = message.text;
        if (message.mediaType == -2) {
            text = SetTitle(@"message_pic");
        }else if (message.mediaType == -3) {
            text = SetTitle(@"message_audio");
        }
        text = [NSString stringWithFormat:@"%@:%@",message.clientId,text];
        
        //发推送
        AVQuery *queryquery = [AVInstallation query];
        [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
        [queryquery whereKey:@"cid" equalTo:[DataShare sharedService].clientObject.clientId];
        [queryquery whereKey:@"deviceProfile" equalTo:@"CAPP"];
        AVPush *push = [[AVPush alloc] init];
        [push setQuery:queryquery];
        NSDictionary *data = @{
                               @"alert": text,
                               @"type": @"2",
                               @"sendNick":message.clientId,
                               @"badge":@"1"
                               };
        [push setData:data];
        [AVPush setProductionMode:YES];
        [push sendPushInBackground];
        
        completionHandler(YES, nil);
    }];
}
/**
 *   头像开启圆角设置
 */
- (void)lcck_setupAvatarImageCornerRadius {
    [[LCChatKit sharedInstance] setAvatarImageViewCornerRadiusBlock:^CGFloat(CGSize avatarImageViewSize) {
         if (avatarImageViewSize.height > 0) {
             return avatarImageViewSize.height / 2;
         }
         return 5;
     }];
}

/**
 *  设置Badge
 */
- (void)lcck_setupBadge {
    //    TabBar样式，自动设置。如果不是TabBar样式，请实现该 Blcok 来设置 Badge 红标。
    [[LCChatKit sharedInstance] setMarkBadgeWithTotalUnreadCountBlock:^(
                                                                        NSInteger totalUnreadCount, UIViewController *controller) {
        if (totalUnreadCount > 0) {
            NSString *badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
            if (totalUnreadCount > 99) {
                badgeValue = LCCKBadgeTextForNumberGreaterThanLimit;
            }
            [controller tabBarItem].badgeValue = badgeValue;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadCount];
        } else {
            [controller tabBarItem].badgeValue = nil;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
    }];
}

@end
