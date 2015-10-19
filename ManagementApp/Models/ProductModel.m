//
//  ProductModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductModel.h"

@implementation ProductModel

+ (NSDictionary*)mts_mapping {
    return  @{@"productId": mts_key(productId),
              @"productCode": mts_key(productCode),
              @"productPriceModel": mts_key(productPriceModel),
              @"purchaseprice": mts_key(purchaseprice),
              @"packageNum": mts_key(packageNum),
              @"productName": mts_key(productName),
              @"productMaterial": mts_key(productMaterial),
              @"sortModel": mts_key(sortModel),
              @"productMark": mts_key(productMark),
              @"isDisplay": mts_key(isDisplay),
              @"isHot": mts_key(isHot),
              @"stockWarningModel": mts_key(stockWarningModel),
              @"productStockArray": mts_key(productStockArray)
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

+ (NSDictionary*)mts_arrayClassMapping
{
    return @{mts_key(productPriceModel) : ProductPriceModel.class,
             mts_key(sortModel) : SortModel.class,
             mts_key(stockWarningModel) : StockWarningModel.class,
             mts_key(productStockArray) : ProductStockModel.class
             };
}

@end