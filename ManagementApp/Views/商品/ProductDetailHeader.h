//
//  ProductDetailHeader.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/23.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductModel.h"

@interface ProductDetailHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) ProductModel *productModel;

@property (nonatomic, copy) void (^segmentChange)(NSInteger index);
@end
