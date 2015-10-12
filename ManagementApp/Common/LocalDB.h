//
//  LocalDB.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "LocalDataBase.h"

@interface LocalDB : LocalDataBase

+(LocalDB *)sharedWQLocalDB;

/*
#pragma mark - 用户
-(void)saveUserDataToLocal:(WQUserObj *)user completeBlock:(void (^)(BOOL finished))compleBlock;
-(void)getLocalUserDataWithCompleteBlock:(void (^)(NSArray *array))compleBlock;
-(void)deleteLocalUserWithCompleteBlock:(void (^)(BOOL finished))compleBlock;


#pragma mark - 最近联系人列表
-(void)saveCustomerDataToLocal:(WQCustomerObj *)customerObj completeBlock:(void (^)(BOOL finished))compleBlock;
-(void)getLocalCustomerWithCompleteBlock:(void (^)(NSArray *array))compleBlock;
-(void)deleteLocalCustomerWithCustomerId:(NSString *)customerId completeBlock:(void (^)(BOOL finished))compleBlock;

#pragma mark - 消息
-(void)saveMessageToLocal:(WQMessageObj *)messageObj completeBlock:(void (^)(BOOL finished))compleBlock;
-(void)getLocalMessageWithId:(NSString *)id1 Id:(NSString *)id2 start:(NSString *)start completeBlock:(void (^)(NSArray *array))compleBlock;
-(void)getLatestMessageWithId:(NSString *)id1 Id:(NSString *)id2 completeBlock:(void (^)(WQMessageObj *messageObj))compleBlock;
 */
@end
