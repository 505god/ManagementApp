//
//  SortModel.m
//  ManagementApp
//
//  Created by ydd on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "SortModel.h"

@implementation SortModel

+ (NSDictionary*)mts_mapping {
    return  @{@"sortId": mts_key(sortId),
              @"sortName": mts_key(sortName),
              @"sortProductCount": mts_key(sortProductCount),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
