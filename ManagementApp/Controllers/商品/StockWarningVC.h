//
//  StockWarningVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

///库存预警

typedef void(^StockWarningVCCompletedBlock)(BOOL success);

@interface StockWarningVC : BaseVC

@property (nonatomic, strong) StockWarningVCCompletedBlock completedBlock;

@end
