//
//  DiscountVC.h
//  ManagementApp
//
//  Created by 邱成西 on 16/11/8.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"

typedef void(^DiscountVCCompletedBlock)(NSInteger discountType,CGFloat discount);

@interface DiscountVC : BaseVC

@property (nonatomic, assign) NSInteger discountType;


@property (nonatomic, assign) CGFloat discount;

@property (nonatomic, copy) DiscountVCCompletedBlock completedBlock;
@end
