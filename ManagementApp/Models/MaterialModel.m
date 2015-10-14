//
//  MaterialModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "MaterialModel.h"

@implementation MaterialModel

+ (NSDictionary*)mts_mapping {
    return  @{@"sortId": mts_key(materialId),
              @"sortName": mts_key(materialName),
              @"sortProductCount": mts_key(productCount),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
