//
//  ProductModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductPriceModel.h"
#import "SortModel.h"
#import "StockWarningModel.h"
#import "ProductStockModel.h"
#import "MaterialModel.h"

@interface ProductModel : NSObject

///商品id
@property (nonatomic, assign) NSInteger productId;

///商品货号必填
@property (nonatomic, strong) NSString *productCode;

///商品价格必填
@property (nonatomic, strong) ProductPriceModel *productPriceModel;

///进货价
@property (nonatomic, assign) CGFloat purchaseprice;

///包装数
@property (nonatomic, assign) NSInteger packageNum;

///名称
@property (nonatomic, strong) NSString *productName;

///材质
@property (nonatomic, strong) MaterialModel *materialModel;

///分类
@property (nonatomic, strong) SortModel *sortModel;

///备注
@property (nonatomic, strong) NSString *productMark;

///上架
@property (nonatomic, assign) BOOL isDisplay;

///热卖
@property (nonatomic, assign) BOOL isHot;

///库存警告
@property (nonatomic, strong) StockWarningModel *stockWarningModel;

///商品库存
@property (nonatomic, strong) NSMutableArray *productStockArray;
@end
