//
//  REProductItemCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/18.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RETableViewTextCell.h"

#import "REProductItem.h"

@interface REProductItemCell : RETableViewTextCell

@property (strong, readwrite, nonatomic) REProductItem *item;

@end
