//
//  RECompanyDayItemCell.h
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "RETableViewTextCell.h"

#import "RECompanyDayItem.h"

@interface RECompanyDayItemCell : RETableViewTextCell

@property (strong, readwrite, nonatomic) RECompanyDayItem *item;

@end
