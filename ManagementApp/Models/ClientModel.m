//
//  ClientModel.m
//  ManagementApp
//
//  Created by ydd on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientModel.h"

@implementation ClientModel


+ (NSDictionary*)mts_mapping {
    return  @{@"clientId": mts_key(clientId),
              @"clientName": mts_key(clientName),
              @"sclientCount": mts_key(clientCount),
              };
}


+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
