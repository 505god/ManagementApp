//
//  MessageModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (nonatomic, strong) NSString *messageId;

///消息来自
@property (nonatomic, assign) NSInteger messageFrom;
///消息发送到
@property (nonatomic, assign) NSInteger messageTo;
///消息内容
@property (nonatomic, strong) NSString *messageContent;
///消息日期
@property (nonatomic, strong) NSString *messageDate;
///消息类型
@property (nonatomic, assign) MessageType messageType;
///消息语音
@property (nonatomic, strong) NSString *messageVoicePath;
///消息来源
@property (nonatomic, assign) MessageFrom fromType;
///显示时间
@property (nonatomic, assign) BOOL showDateLabel;
@property (nonatomic, strong) NSString *messageShowDate;


+(MessageModel *)messageFromDictionary:(NSDictionary *)aDic;

//显示日期与否
- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;

@end
