//
//  ClassifyCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RMSwipeTableViewCell.h"

#import "SortModel.h"

@interface ClassifyCell : RMSwipeTableViewCell

@property (nonatomic, strong) SortModel *sortModel;

///用于编辑时标记位置
@property (nonatomic, strong) NSIndexPath *indexPath;

///选择时 0=隐藏  1=normal  2=highted
@property (nonatomic, assign) NSInteger selectedType;

@end
