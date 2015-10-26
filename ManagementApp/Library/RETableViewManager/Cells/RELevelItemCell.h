//
//  RELevelItemCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RETableViewCell.h"
#import "RELevelItem.h"

@interface RELevelItemCell : RETableViewCell

@property (strong, readwrite, nonatomic) RELevelItem *item;

@end
