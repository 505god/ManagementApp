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

-(void)setResultArray:(NSArray *)resultArray {
    _resultArray = resultArray;
    
    self.nameLab.adjustsFontSizeToFitWidth = YES;
    self.nameLab.text = [NSString stringWithFormat:@"%@",resultArray[0]];
    self.countLab.text = [NSString stringWithFormat:@"%d",[resultArray[1] intValue]];
}

-(void)setSortModel:(SortModel *)sortModel {
    _sortModel = sortModel;
    
    self.nameLab.adjustsFontSizeToFitWidth = YES;
    self.nameLab.text = [NSString stringWithFormat:@"%@",sortModel.sortName];
    self.countLab.text = [NSString stringWithFormat:@"%d",(int)sortModel.productCount];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
