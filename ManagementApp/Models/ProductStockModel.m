//
//  ProductStockModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductStockModel.h"

@implementation ProductStockModel

+(ProductStockModel *)initWithObject:(AVObject *)object {
    
    ProductStockModel *model = [[ProductStockModel alloc]init];
    
    AVFile *attachment = [object objectForKey:@"header"];
    if (attachment != nil) {
        model.picHeader = attachment.url;
    }
    
    AVObject *object15 = [object objectForKey:@"color"];
    if (object15 != nil) {
        [object15 fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            ColorModel *model12 = [ColorModel initWithObject:object];
            model.colorModel = model12;
        }];
    }
    
    NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
    [model mts_setValuesForKeysWithDictionary:dic];
    model.ProductStockId = object.objectId;
    model.stockNum = model.num-model.saleANum-model.saleBNum-model.saleCNum-model.saleDNum;
    
    return model;
}


+ (NSDictionary*)mts_mapping {
    return  @{
              @"stockNum": mts_key(num),
              @"saleA": mts_key(saleANum),
              @"saleB": mts_key(saleBNum),
              @"saleC": mts_key(saleCNum),
              @"saleD": mts_key(saleDNum),
              @"hot": mts_key(isHot),
              @"sale": mts_key(isDisplay),
              @"pcode": mts_key(pcode),
              @"saleNum": mts_key(saleNum),
              @"a": mts_key(aPrice),
              @"b": mts_key(bPrice),
              @"c": mts_key(cPrice),
              @"d": mts_key(dPrice),
              @"selected": mts_key(selected),
              @"colorName": mts_key(colorName),
              @"isSetting": mts_key(isSetting),
              @"singleNum": mts_key(singleNum),
              @"purchasePrice": mts_key(purchaseprice),
              @"isWarning": mts_key(isWarning)
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
