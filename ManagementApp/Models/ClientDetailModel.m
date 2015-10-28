//
//  ClientDetailModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientDetailModel.h"

@implementation ClientDetailModel

+ (NSDictionary*)mts_mapping {
    return  @{@"clientDetailId": mts_key(clientDetailId),
              @"clientDetailCode": mts_key(clientDetailCode),
              @"totalPrice": mts_key(totalPrice),
              
              @"totalNum": mts_key(totalNum),
              @"time": mts_key(time)
              };
}


+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}


@end
