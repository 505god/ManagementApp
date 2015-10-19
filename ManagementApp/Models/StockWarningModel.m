//
//  StockWarningModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "StockWarningModel.h"

@implementation StockWarningModel

+ (NSDictionary*)mts_mapping {
    return  @{@"isSetting": mts_key(isSetting),
              @"totalNum": mts_key(totalNum),
              @"singleNum": mts_key(singleNum)
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
