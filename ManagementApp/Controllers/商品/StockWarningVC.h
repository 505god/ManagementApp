//
//  StockWarningVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

///库存预警


#import "StockWarningModel.h"

typedef void(^StockWarningVCCompletedBlock)(StockWarningModel *stockWarningModel,BOOL editting);

@interface StockWarningVC : BaseVC

@property (nonatomic, strong) StockWarningVCCompletedBlock completedBlock;

///从上个页面传过来
@property (nonatomic, strong) StockWarningModel *stockWarningModel;
@end
