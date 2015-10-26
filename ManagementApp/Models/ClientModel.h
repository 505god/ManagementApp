//
//  ClientModel.h
//  ManagementApp
//
//  Created by ydd on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientModel : NSObject

///客户id
@property (nonatomic, assign) NSInteger clientId;

///客户类型 0=顾客  1=供货商
@property (nonatomic, assign) NSInteger clientType;

///客户等级
@property (nonatomic, assign) NSInteger clientLevel;

///客户名称
@property (nonatomic, strong) NSString *clientName;

///客户电话
@property (nonatomic, strong) NSString *clientPhone;

///客户邮箱
@property (nonatomic, strong) NSString *clientEmail;

///客户备注
@property (nonatomic, strong) NSString *clientRemark;

///私密客户
@property (nonatomic, assign) BOOL isPrivate;

@property (nonatomic, assign) CGFloat totalPrice;

@end
