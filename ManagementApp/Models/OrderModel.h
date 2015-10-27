//
//  OrderModel.h
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>
///订单 model
@interface OrderModel : NSObject

@property (nonatomic, copy) NSString *orderId;
///客户名称
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) double orderTime;

@property (nonatomic, assign) NSInteger orderCount;

@property (nonatomic, assign) NSInteger totalMoney;

@property (nonatomic, assign) NSInteger orderState;
@end
