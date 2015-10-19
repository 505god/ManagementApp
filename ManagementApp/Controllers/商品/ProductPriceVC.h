//
//  ProductPriceVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

///价格

#import "RETableViewManager.h"
#import "ProductPriceModel.h"

typedef void(^ProductPriceVCCompletedBlock)(ProductPriceModel *productPriceModel, BOOL editting);


@interface ProductPriceVC : BaseVC

@property (nonatomic, strong) ProductPriceVCCompletedBlock completedBlock;

@property (nonatomic, weak) IBOutlet UITableView *table;

@property (strong, readonly, nonatomic) RETableViewManager *manager;

///从上个页面传过来
@property (nonatomic, strong) ProductPriceModel *productPriceModel;
@end
