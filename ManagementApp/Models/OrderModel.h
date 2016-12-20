//
//  OrderModel.h
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>
///订单 model

#import "ClientModel.h"

@interface OrderModel : NSObject

@property (nonatomic, copy) NSString *orderId;

@property (nonatomic, copy) NSString *orderCode;

@property (nonatomic, copy) NSString *payType;

@property (nonatomic, assign) CGFloat orderPrice;

@property (nonatomic, copy) NSString *orderMark;

@property (nonatomic, assign) NSInteger discountType;

@property (nonatomic, assign) CGFloat discount;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientName;

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, assign) NSInteger orderCount;

@property (nonatomic, assign) NSInteger orderStatus;
@property (nonatomic, assign) CGFloat tax;
@property (nonatomic, assign) CGFloat taxNum;
@property (nonatomic, assign) CGFloat profit;
///0=未付款  1=部分付款  2=全部付款
@property (nonatomic, assign) NSInteger isPay;

///0=未发货  1=部分发货  2=全部发货
@property (nonatomic, assign) NSInteger isDeliver;

@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, strong) NSMutableArray *productArray;

@property (nonatomic, strong) ClientModel *clientModel;
@property (nonatomic, assign) CGFloat arrearsPrice;

@property (nonatomic, assign) BOOL ered;
@property (nonatomic, assign) BOOL cred;

+(OrderModel *)initWithObject:(AVObject *)object;
@end
