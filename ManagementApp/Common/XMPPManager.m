//
//  XMPPManager.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "XMPPManager.h"

@implementation XMPPManager

static XMPPManager *sharedManager;

+(XMPPManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[XMPPManager alloc]init];
    });
    return sharedManager;
}


- (void)setupStream{
    self.xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        self.xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    [self.xmppReconnect activate:self.xmppStream];
    
    [self.xmppStream setHostName:@"120.24.64.85"];
    [self.xmppStream setHostPort:5222];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.customCertEvaluation = YES;
    
    BOOL hasConnect = [self.xmppStream isConnected];
    if (!hasConnect)
    {
        [self myConnect];
    }
}

#pragma mark - xmpp链接
- (BOOL)myConnect{
    //设置用户
//    XMPPJID *myjid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d_sale@ubuntu",[DataShare sharedService].userObj.userId]];
//    NSError *error ;
//    [self.xmppStream setMyJID:myjid];
//    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
//        return NO;
//    }
    
    return YES;
}

#pragma mark - 释放
- (void)teardownStream{
    [self.xmppStream removeDelegate:self];
    
    [self.xmppReconnect deactivate];
    
    [self.xmppStream disconnect];
    
    self.xmppStream = nil;
    self.xmppReconnect = nil;
}
//发送在线状态
- (void)goOnline{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    [self.xmppStream sendElement:presence];
}

//发送下线状态
- (void)goOffline{
    //    [self getOffLineMessage];
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

- (void)disconnect{
    [self goOffline];
    [self.xmppStream disconnect];
}


#pragma mark - 获取离线消息
-(void)getOffLineMessage {
    
//    NSString *jid = [NSString stringWithFormat:@"%d_sale@ubuntu",[WQDataShare sharedService].userObj.userId];
//    XMPPIQ *iq = [[XMPPIQ alloc] initWithXMLString:[NSString stringWithFormat:@"<presence from='%@'><priority>1</priority></presence>",jid]error:nil];
//    [self.xmppStream sendElement:iq];
}

#pragma mark - XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings{
    NSString *expectedCertName = [self.xmppStream.myJID domain];
    if (expectedCertName) {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
    
    if (self.customCertEvaluation) {
        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender{
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamWillConnect:(XMPPStream *)sender {
}
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    DLog(@"xmpp连接成功");
//    if ([WQDataShare sharedService].idRegister) {
//        NSError *error;
//        if (![self.xmppStream authenticateWithPassword:@"111111" error:&error]){
//        }
//    }else {
//        if ([self.xmppStream isConnected] && [self.xmppStream supportsInBandRegistration]) {
//            XMPPJID *myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d_sale@ubuntu",[WQDataShare sharedService].userObj.userId]];
//            [self.xmppStream setMyJID:myJID];
//            
//            NSError *error ;
//            [WQDataShare sharedService].idRegister = [self.xmppStream registerWithPassword:@"111111" error:&error];
//            [[NSUserDefaults standardUserDefaults] setBool:[WQDataShare sharedService].idRegister forKey:[NSString stringWithFormat:@"register_%ld",[WQDataShare sharedService].userObj.userId]];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
}

//注册成功，则授权
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"register_%ld",[WQDataShare sharedService].userObj.userId]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    NSError *error ;
//    if (![self.xmppStream authenticateWithPassword:@"111111" error:&error]) {
//    }
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"register_%ld",[WQDataShare sharedService].userObj.userId]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    if (![self.xmppStream authenticateWithPassword:@"111111" error:nil]) {
//    }
}
//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];
    [self getOffLineMessage];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
}
//好友列表
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    return YES;
}
//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    NSXMLElement *request = [message elementForName:@"request"];
    if (request) {
        if ([request.xmlns isEqualToString:@"urn:xmpp:receipts"]) {//消息回执
            //组装消息回执
            XMPPMessage *msg = [XMPPMessage messageWithType:[message attributeStringValueForName:@"type"] to:message.from elementID:message.elementID];
            NSXMLElement *recieved = [NSXMLElement elementWithName:@"received" xmlns:@"urn:xmpp:receipts"];
            [msg addChild:recieved];
            
            //发送回执
            [self.xmppStream sendElement:msg];
            
            if ([self.chatDelegate respondsToSelector:@selector(getNewMessage:Message:)]) {
                [self.chatDelegate getNewMessage:self Message:message];
            }
        }
    }
    else {
        NSXMLElement *received = [message elementForName:@"received"];
        if (received)
        {
            if ([received.xmlns isEqualToString:@"urn:xmpp:receipts"])//消息回执
            {
                DLog(@"message send success!");
            }
        }
    }
}
//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if (presence.status) {
        if ([self.chatDelegate respondsToSelector:@selector(friendStatusChange:Presence:)]) {
            [self.chatDelegate friendStatusChange:self Presence:presence];
        }
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {
    DLog(@"接受发生错误: %@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq {
    DLog(@"didSendIQ:%@",iq.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSXMLElement *request = [message elementForName:@"request"];
    if (request) {
        if ([request.xmlns isEqualToString:@"urn:xmpp:receipts"]) {//消息回执
            if ([self.chatDelegate respondsToSelector:@selector(didSendMessage:Message:)])
            {
                [self.chatDelegate didSendMessage:self Message:message];
            }
        }
    }
    
    //    if ([self.chatDelegate respondsToSelector:@selector(didSendMessage:Message:)]) {
    //        [self.chatDelegate didSendMessage:self Message:message];
    //    }
}
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    DLog(@"状态改变成功:%@",presence.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
    DLog(@"didFailToSendIQ:%@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    
    if ([self.chatDelegate respondsToSelector:@selector(senMessageFailed:Message:)]) {
        [self.chatDelegate senMessageFailed:self Message:message];
    }
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error {
}
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender {
    DLog(@"xmppStreamWasToldToDisconnect");
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    DLog(@"连接超时");
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    DLog(@"连接失败: %@",error.description);
}
#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    //接收到别人的添加好友请求，默认自动添加为好友
}
#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags {
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags {
    return YES;
}

@end
