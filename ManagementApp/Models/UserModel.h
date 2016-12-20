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
@property (nonatomic, assign) BOOL phoneVerified;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) BOOL emailVerified;

@property (nonatomic, assign) CGFloat tax;

@property (nonatomic, strong) NSString *header;
@property (nonatomic, assign) double expireDate;

@property (nonatomic, assign) BOOL rule;

@property (nonatomic, assign) BOOL isExpire;
//使用剩余天数
@property (nonatomic, assign) NSInteger dayNumber;
@property (nonatomic, assign) NSInteger hourNumber;
@property (nonatomic, assign) NSInteger minuteNumber;

@property (nonatomic, assign) NSInteger type;

+(UserModel *)initWithObject:(AVObject *)object;

@end
