//
//  UserModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/25.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *userHead;

@property (nonatomic, assign) NSInteger day;
@property (nonatomic, copy) NSString *dayId;
@property (nonatomic, assign) BOOL isExpire;

@property (nonatomic, strong) NSDate *createdAt;

@property (nonatomic, strong) NSString *dayString;

@property (nonatomic, strong) NSString *dayNumber;

+(UserModel *)initWithObject:(AVObject *)object;

-(BOOL)checkExpire;
@end
