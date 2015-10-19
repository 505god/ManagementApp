//
//  ProductPriceModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductPriceModel.h"

@implementation ProductPriceModel

+ (NSDictionary*)mts_mapping {
    return  @{@"aPrice": mts_key(aPrice),
              @"bPrice": mts_key(bPrice),
              @"cPrice": mts_key(cPrice),
              @"dPrice": mts_key(dPrice)
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
