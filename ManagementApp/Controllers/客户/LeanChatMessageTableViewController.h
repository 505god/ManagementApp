//
//  LeanChatMessageTableViewController.h
//  MessageDisplayKitLeanchatExample
//
//  Created by Jack_iMac on 15/3/21.
//  Copyright (c) 2015年 iOS软件开发工程师 曾宪华 热衷于简洁的UI QQ:543413507 http://www.pailixiu.com/blog   http://www.pailixiu.com/Jack/personal. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "ClientModel.h"

@interface LeanChatMessageTableViewController : XHMessageTableViewController

@property (nonatomic, strong) ClientModel *clientModel;


- (instancetype)initWithClientIDs:(NSArray *)clientIDs;

@end
