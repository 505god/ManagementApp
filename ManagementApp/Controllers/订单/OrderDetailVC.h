//
//  OrderDetailVC.h
//  BApp
//
//  Created by 邱成西 on 16/1/11.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"
#import "OrderModel.h"

@interface OrderDetailVC : BaseVC

@property(strong, nonatomic) OrderModel *orderModel;
@property(strong, nonatomic) NSIndexPath *idxPath;
@property(copy, nonatomic) void (^deleteHandler)(NSIndexPath *idxPath);
@property(copy, nonatomic) void (^refreshHandler)(OrderModel *orderModel,NSIndexPath *idxPath);
@end
