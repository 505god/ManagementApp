//
//  OrderStockModel.m
//  BApp
//
//  Created by 邱成西 on 16/1/11.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "OrderStockModel.h"

@implementation OrderStockModel

+ (NSDictionary*)mts_mapping {
    return  @{@"num": mts_key(num),
              @"colorName": mts_key(colorName),
              @"header": mts_key(header),
              @"oid": mts_key(oid),
              @"pcode": mts_key(pcode),
              @"price": mts_key(price),
              @"clientName": mts_key(clientName),
              @"clientLevel": mts_key(clientLevel),
              @"purchasePrice": mts_key(purchasePrice)
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

-(NSString *)timeString {
    return [self.creat stringLoacalDateWithFormat:@"dd/MM"];
}
@end
