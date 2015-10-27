//
//  OrderModel.m
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderModel.h"

@implementation OrderModel
+ (NSDictionary*)mts_mapping {
    return  @{@"orderId": mts_key(orderId),
              @"userName": mts_key(userName),
              @"orderTime": mts_key(orderTime),
              @"orderCount": mts_key(orderCount),
              @"totalMoney": mts_key(totalMoney),
              @"orderState": mts_key(orderState),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
