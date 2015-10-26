//
//  RELevelItem.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RETableViewItem.h"

@interface RELevelItem : RETableViewItem

@property (nonatomic, assign) NSInteger currentIndex;

@property (copy, readwrite, nonatomic) void (^onChange)(RELevelItem *item);

+ (instancetype)itemWithTitle:(NSString *)title index:(NSInteger)index;
-(id)initWithTitle:(NSString *)title index:(NSInteger)index;
@end
