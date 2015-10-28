//
//  WQChatManager.m
//  App
//
//  Created by 邱成西 on 15/5/6.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQChatManager.h"
#import "LocalDB.h"

#import "WQMessageFrame.h"

static NSString *previousTime = nil;

@implementation WQChatManager

#pragma mark - setter

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

-(void)setClientModel:(ClientModel *)clientModel {
    _clientModel = clientModel;
}

#pragma mark - 聊天记录
-(void)getLocalMessageWithId:(NSString *)id1 Id2:(NSString *)id2 start:(NSInteger)start completeBlock:(void (^)(BOOL isCanLoadingMore,NSInteger count))compleBlock{
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [[LocalDB sharedWQLocalDB]getLocalMessageWithId:id1 Id:id2 start:[NSString stringWithFormat:@"%d",(int)start] completeBlock:^(NSArray *array) {
        
        BOOL isCanLoad = array.count<10?NO:YES;
        
        if (array.count>0) {
            for (NSInteger i=array.count-1; i>=0; i--) {
                MessageModel *messageObj = (MessageModel *)array[i];
                WQMessageFrame *messageFrame = [weakSelf unionMessageFrameWithMessage:messageObj];
                [weakSelf.dataArray addObject:messageFrame];
            }
        }
        
        if (compleBlock) {
            compleBlock(isCanLoad,array.count);
        }
    }];
}

-(void)getNextLocalMessageWithId:(NSString *)id1 Id2:(NSString *)id2 start:(NSInteger)start completeBlock:(void (^)(BOOL isCanLoadingMore,NSInteger count))compleBlock{
    __unsafe_unretained typeof(self) weakSelf = self;
    [[LocalDB sharedWQLocalDB] getLocalMessageWithId:id1 Id:id2 start:[NSString stringWithFormat:@"%d",(int)start] completeBlock:^(NSArray *array) {
        
        BOOL isCanLoad = array.count<10?NO:YES;
        
        if (array.count>0) {
            NSInteger arrayCount = weakSelf.dataArray.count;
            for (NSInteger i=array.count-1; i>=0; i--) {
                MessageModel *messageObj = (MessageModel *)array[i];
                WQMessageFrame *messageFrame = [weakSelf unionMessageFrameWithMessage:messageObj];
                [weakSelf.dataArray insertObject:messageFrame atIndex:(weakSelf.dataArray.count-arrayCount)];
            }
        }
        
        if (compleBlock) {
            compleBlock(isCanLoad,array.count);
        }
    }];
}

-(WQMessageFrame *)unionMessageFrameWithMessage:(MessageModel *)messageObj {
    WQMessageFrame *messageFrame = [[WQMessageFrame alloc]init];
    
    [messageObj minuteOffSetStart:previousTime end:messageObj.messageDate];
    if (messageObj.showDateLabel){
        previousTime = messageObj.messageDate;
    }
    messageFrame.messageObj = messageObj;
    
    if (messageObj.fromType == WQMessageFromMe) {
        ClientModel *customer = [[ClientModel alloc]init];
        customer.clientId = [DataShare sharedService].userModel.userId;
        customer.clientName = [DataShare sharedService].userModel.userName;
        customer.userHead = [DataShare sharedService].userModel.userHead;
        messageFrame.customerObj = customer;
    }else {
        messageFrame.customerObj = self.clientModel;
    }
    
    return messageFrame;
}

-(void)addMessageFrameWithMessageObj:(MessageModel *)messageObj {
    WQMessageFrame *messageFrame = [[WQMessageFrame alloc]init];
    
    [messageObj minuteOffSetStart:previousTime end:messageObj.messageDate];
    if (messageObj.showDateLabel){
        previousTime = messageObj.messageDate;
    }
    messageFrame.messageObj = messageObj;
    
    if (messageObj.fromType == WQMessageFromMe) {
        ClientModel *customer = [[ClientModel alloc]init];
        customer.clientId = [DataShare sharedService].userModel.userId;
        customer.clientName = [DataShare sharedService].userModel.userName;
        customer.userHead = [DataShare sharedService].userModel.userHead;
        messageFrame.customerObj = customer;
    }else {
        messageFrame.customerObj = self.clientModel;
    }
    
    [self.dataArray addObject:messageFrame];
}
@end
