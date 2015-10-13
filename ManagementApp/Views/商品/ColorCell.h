//
//  ColorCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RMSwipeTableViewCell.h"

#import "ColorModel.h"

@interface ColorCell : RMSwipeTableViewCell

@property (nonatomic, strong) ColorModel *colorModel;

///用于编辑时标记位置
@property (nonatomic, strong) NSIndexPath *indexPath;

///选择时 0=隐藏  1=normal  2=highted
@property (nonatomic, assign) NSInteger selectedType;

@property (nonatomic, assign) BOOL isCanSelected;

@end
