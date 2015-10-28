//
//  LocalDB.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "LocalDB.h"

@interface LocalDB (DBPrivate)
//-(WQUserObj *)userModelFromLocal:(FMResultSet *)rs;
-(ClientModel *)customerModelFromLocal:(FMResultSet *)rs;
-(MessageModel *)messageModelFromLocal:(FMResultSet *)rs;
@end

@implementation LocalDB (DBPrivate)
//-(WQUserObj *)userModelFromLocal:(FMResultSet *)rs {
//    WQUserObj *userObj = [[WQUserObj alloc]init];
//    userObj.userId = [[rs stringForColumn:@"userId"] integerValue];
//    userObj.userHead = [rs stringForColumn:@"userHead"];
//    userObj.userName = [rs stringForColumn:@"userName"];
//    userObj.password = [rs stringForColumn:@"password"];
//    userObj.userPhone = [rs stringForColumn:@"userPhone"];
//    userObj.moneyType = [[rs stringForColumn:@"moneyType"]integerValue];
//    return userObj;
//}
-(ClientModel *)customerModelFromLocal:(FMResultSet *)rs {
    ClientModel *customerObj = [[ClientModel alloc]init];
    customerObj.clientId = [[rs stringForColumn:@"clientId"] integerValue];
    customerObj.clientType = [[rs stringForColumn:@"clientType"] integerValue];
    customerObj.clientLevel = [[rs stringForColumn:@"clientLevel"]integerValue];
    customerObj.clientName = [rs stringForColumn:@"clientName"];
    customerObj.clientPhone = [rs stringForColumn:@"clientPhone"];
    customerObj.clientEmail = [rs stringForColumn:@"clientEmail"];
    customerObj.clientRemark = [rs stringForColumn:@"clientRemark"];
    customerObj.isPrivate = [[rs stringForColumn:@"isPrivate"] boolValue];
    
    customerObj.command = [rs stringForColumn:@"customerCode"];
    customerObj.isCommand = [[rs stringForColumn:@"isCommand"] boolValue];
    customerObj.isShowPrice = [[rs stringForColumn:@"isShowPrice"] boolValue];
    return customerObj;
}
-(MessageModel *)messageModelFromLocal:(FMResultSet *)rs {
    MessageModel *messageObj = [[MessageModel alloc]init];
    messageObj.messageFrom = [[rs stringForColumn:@"messageFrom"] integerValue];
    messageObj.messageTo = [[rs stringForColumn:@"messageTo"] integerValue];
    messageObj.messageContent = [rs stringForColumn:@"messageContent"];
    messageObj.messageDate = [rs stringForColumn:@"messageDate"];
    messageObj.messageType = [[rs stringForColumn:@"messageType"]integerValue];
    messageObj.messageId = [rs stringForColumn:@"messageId"];

    if (messageObj.messageFrom == [DataShare sharedService].userModel.userId) {
        messageObj.fromType = WQMessageFromMe;
    }else {
        messageObj.fromType = WQMessageFromOther;
    }
    
    return messageObj;
}

@end

@implementation LocalDB

+(LocalDB *)sharedWQLocalDB {
    static LocalDB *sharedRPLocalDB=nil;
    
    @synchronized(self)
    {
        if (!sharedRPLocalDB)
            sharedRPLocalDB = [[LocalDB alloc] init];
        
        return sharedRPLocalDB;
    }
}

/*
#pragma mark - 用户

-(void)saveUserDataToLocal:(WQUserObj *)user completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    [self.db executeUpdate:@"delete from WQUser"];
    
    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:4];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",user.userId]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.userName]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.userHead]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",user.moneyType]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.password]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.userPhone]];
    BOOL res = [self.db executeUpdate:@"insert into WQUser (userId,userName,userHead,moneyType,password,userPhone) values (?,?,?,?,?,?)" withArgumentsInArray:argumentsArray];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}
-(void)getLocalUserDataWithCompleteBlock:(void (^)(NSArray *array))compleBlock {
    [self.db open];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    FMResultSet * rs = [self.db executeQuery:@"select * from WQUser"];
    
    while ([rs next]) {
        WQUserObj *tempUser = [self userModelFromLocal:rs];
        [mutableArray addObject:tempUser];
        tempUser = nil;
    }
    
    [rs close];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(mutableArray);
    }
}
-(void)deleteLocalUserWithCompleteBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    BOOL res = [self.db executeUpdate:@"delete from WQUser"];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}
*/

#pragma mark - 最近联系人列表

-(void)saveCustomerDataToLocal:(ClientModel *)customerObj completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    FMResultSet * rs = [self.db executeQuery:@"select * from Client where clientId=?",[NSString stringWithFormat:@"%d",(int)customerObj.clientId]];
    
    BOOL isExit = NO;
    ClientModel *tempCustomer = [[ClientModel alloc]init];
    while ([rs next]) {
        tempCustomer = [self customerModelFromLocal:rs];
        if (tempCustomer.clientId==customerObj.clientId) {
            isExit = YES;
            break;
        }
    }
    [rs close];
    
    if (isExit==YES) {
        BOOL res = [self.db executeUpdate:@"update Client set clientName=?,clientPhone=?,clientEmail=?,clientRemark=?,isPrivate=?,command=?,isCommand=?,isShowPrice=?,clientType=? where clientId= ?",customerObj.clientName,customerObj.clientPhone,customerObj.clientEmail,customerObj.clientRemark,[NSString stringWithFormat:@"%d",customerObj.isPrivate],customerObj.command,[NSString stringWithFormat:@"%d",customerObj.isCommand],[NSString stringWithFormat:@"%d",customerObj.isShowPrice],[NSString stringWithFormat:@"%d",(int)customerObj.clientType],[NSString stringWithFormat:@"%d",(int)customerObj.clientId]];
        
        [self.db close];
        
        if (compleBlock) {
            compleBlock(res);
        }
    }else {
        NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:11];
        [argumentsArray addObject:[NSString stringWithFormat:@"%d",(int)customerObj.clientId]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%ld",customerObj.clientType]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%ld",customerObj.clientLevel]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%@",customerObj.clientName]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%@",customerObj.clientPhone]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%@",customerObj.clientEmail]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%@",customerObj.clientRemark]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%d",customerObj.isPrivate]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%@",customerObj.command]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%d",customerObj.isCommand]];
        [argumentsArray addObject:[NSString stringWithFormat:@"%d",customerObj.isShowPrice]];
        
        BOOL res = [self.db executeUpdate:@"insert into Client (clientId,clientType,clientLevel,clientName,clientPhone,clientEmail,clientRemark,isPrivate,command,isCommand,isShowPrice) values (?,?,?,?,?,?,?,?,?,?,?)" withArgumentsInArray:argumentsArray];
        
        [self.db close];
        
        if (compleBlock) {
            compleBlock(res);
        }
    }
}
-(void)getLocalCustomerWithCompleteBlock:(void (^)(NSArray *array))compleBlock {
    [self.db open];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    FMResultSet * rs = [self.db executeQuery:@"select * from Client"];
    
    while ([rs next]) {
        ClientModel *customerObj = [self customerModelFromLocal:rs];
        [mutableArray addObject:customerObj];
        customerObj = nil;
    }
    
    [rs close];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(mutableArray);
    }
}
-(void)deleteLocalCustomerWithCustomerId:(NSString *)customerId completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    BOOL res = [self.db executeUpdate:@"delete from Client where clientId = ?",customerId];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}

#pragma mark - 消息
-(void)saveMessageToLocal:(MessageModel *)messageObj completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    //判断存在否messageId
    FMResultSet * rs = [self.db executeQuery:@"select * from WQMessage where messageId=?",messageObj.messageId];
    BOOL isExit = NO;
    while ([rs next]) {
        MessageModel *message = [self messageModelFromLocal:rs];
        if (message != nil) {
            isExit = YES;
            break;
        }
    }
    
    if (isExit == YES) {
        [self.db close];
        
        if (compleBlock) {
            compleBlock(NO);
        }
        return;
    }
    
    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:6];
    [argumentsArray addObject:[NSString stringWithFormat:@"%ld",(long)messageObj.messageFrom]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%ld",(long)messageObj.messageTo]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",messageObj.messageContent]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",messageObj.messageDate]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%ld",(long)messageObj.messageType]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",messageObj.messageId]];
    BOOL res = [self.db executeUpdate:@"insert into WQMessage (messageFrom,messageTo,messageContent,messageDate,messageType,messageId) values (?,?,?,?,?,?)" withArgumentsInArray:argumentsArray];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}

-(void)getLocalMessageWithId:(NSString *)id1 Id:(NSString *)id2 start:(NSString *)start completeBlock:(void (^)(NSArray *array))compleBlock {
    
    if(id1==nil || id2==nil){
        return;
    }
    
    [self.db open];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    FMResultSet * rs = [self.db executeQuery:@"select * from WQMessage where (messageFrom=? and messageTo=?)|(messageFrom=? and messageTo=?) order by id desc limit ?,10",id1,id2,id2,id1,start];
    
    while ([rs next]) {
        MessageModel *message = [self messageModelFromLocal:rs];
        [mutableArray addObject:message];
        message = nil;
    }
    
    [rs close];
    [self.db close];
    
    if (compleBlock) {
        compleBlock(mutableArray);
    }
}
-(void)getLatestMessageWithId:(NSString *)id1 Id:(NSString *)id2 completeBlock:(void (^)(MessageModel *messageObj))compleBlock {
    if(id1==nil || id2==nil){
        return;
    }
    
    [self.db open];
    
    FMResultSet * rs = [self.db executeQuery:@"select * from WQMessage where (messageFrom=? and messageTo=?)|(messageFrom=? and messageTo=?) order by id desc limit 0,1",id1,id2,id2,id1];
    
    MessageModel *messageObj;
    while ([rs next]) {
        messageObj = [self messageModelFromLocal:rs];
    }
    [rs close];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(messageObj);
    }
}

@end
