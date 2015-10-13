//
//  SortCell.h
//  ManagementApp
//
//  Created by ydd on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortModel.h"

@interface SortCell : UITableViewCell

@property (nonatomic, strong) SortModel *sortModel;
///分类名称
@property (nonatomic, weak) IBOutlet UILabel *nameLab;
///分类下的数目
@property (nonatomic, weak) IBOutlet UILabel *countLab;

@end
