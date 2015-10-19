//
//  ProductStockModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductStockModel.h"

@implementation ProductStockModel

+ (NSDictionary*)mts_mapping {
    return  @{@"ProductStockId": mts_key(ProductStockId),
              @"picHeader": mts_key(picHeader),
              @"stockNum": mts_key(stockNum),
              @"color": mts_key(colorModel)
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

+ (NSDictionary*)mts_arrayClassMapping
{
    return @{mts_key(color) : ColorModel.class
             };
}

@end
