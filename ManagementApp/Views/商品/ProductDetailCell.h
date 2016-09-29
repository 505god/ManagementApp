//
//  ProductDetailCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"
#import "ProductStockModel.h"
#import "OrderStockModel.h"
@interface ProductDetailCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *idxPath;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) ProductModel *productModel;

@property (nonatomic, strong) ProductStockModel *productStockModel;

@property (nonatomic, strong) OrderStockModel *orderStockModel;
@end
