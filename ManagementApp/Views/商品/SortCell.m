//
//  SortCell.m
//  ManagementApp
//
//  Created by ydd on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "SortCell.h"

@implementation SortCell

- (void)awakeFromNib {
    // Initialization code
    
}

-(void)setSortModel:(SortModel *)sortModel {
    _sortModel = sortModel;
    
    self.nameLab.adjustsFontSizeToFitWidth = YES;
//    self.nameLab.minimumFontSize = 6;
    self.nameLab.text = [NSString stringWithFormat:@"%@",sortModel.sortName];
    self.countLab.text = [NSString stringWithFormat:@"%d",(int)sortModel.sortProductCount];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
