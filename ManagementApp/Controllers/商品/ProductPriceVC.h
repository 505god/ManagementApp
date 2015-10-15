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


@protocol ProductPriceVCDelegate;

@interface ProductPriceVC : BaseVC

@property (nonatomic, assign) id<ProductPriceVCDelegate>delegate;

@property (nonatomic, weak) IBOutlet UITableView *table;

@property (strong, readonly, nonatomic) RETableViewManager *manager;

@end

@protocol ProductPriceVCDelegate <NSObject>


@end