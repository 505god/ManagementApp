//
//  RELevelItem.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RELevelItem.h"

@implementation RELevelItem

+ (instancetype)itemWithTitle:(NSString *)title index:(NSInteger)index {
    return [[self alloc]initWithTitle:title index:index];
}
-(id)initWithTitle:(NSString *)title index:(NSInteger)index {
    self = [super init];
    if (!self)
        return nil;
    
    self.title = title;
    self.currentIndex = index;
    return self;
}
@end
