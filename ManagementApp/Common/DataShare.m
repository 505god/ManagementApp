//
//  DataShare.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "DataShare.h"

@implementation DataShare
- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (DataShare *)sharedService {
    static dispatch_once_t once;
    static DataShare *dataService = nil;
    
    dispatch_once(&once, ^{
        dataService = [[super alloc] init];
    });
    return dataService;
}
@end
