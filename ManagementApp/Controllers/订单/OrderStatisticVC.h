//
//  OrderStatisticVC.h
//  ManagementApp
//
//  Created by 邱成西 on 16/1/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"

@interface OrderStatisticVC : BaseVC

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *headerArray;

@property (nonatomic, assign) OrderFilterType orderType;//一级
@property (nonatomic, assign) NSInteger type;//二级
@property (nonatomic, copy) NSString *time;

@property (nonatomic, strong) NSArray *filterNameArray;

@end
