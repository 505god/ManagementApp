//
//  ColorModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ColorModel.h"

@implementation ColorModel

+ (NSDictionary*)mts_mapping {
    return  @{@"colorId": mts_key(colorId),
              @"colorName": mts_key(colorName),
              @"productSize": mts_key(productCount),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
