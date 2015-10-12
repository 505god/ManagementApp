//
//  XMPPManager.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///即时聊天

#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"

@protocol ChatDelegate;

@interface XMPPManager : NSObject

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;

@property (nonatomic, assign) BOOL isXmppConnected;
@property (nonatomic, assign) BOOL customCertEvaluation;

@property (nonatomic, assign) id<ChatDelegate>chatDelegate;

- (BOOL)myConnect;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

- (void)getOffLineMessage;

+(XMPPManager *)sharedInstance;

// 获取离线消息
-(void)getOffLineMessage;

@end

@protocol ChatDelegate <NSObject>

@optional
-(void)friendStatusChange:(XMPPManager *)xmppManager Presence:(XMPPPresence *)presence;
-(void)getNewMessage:(XMPPManager *)xmppManager Message:(XMPPMessage *)message;
-(void)didSendMessage:(XMPPManager *)xmppManager Message:(XMPPMessage *)message;
-(void)senMessageFailed:(XMPPManager *)xmppManager Message:(XMPPMessage *)message;
@end
