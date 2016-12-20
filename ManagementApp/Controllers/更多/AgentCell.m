//
//  AgentCell.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AgentCell.h"
#import "UIImageView+WebCache.h"

@interface AgentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *dayLab;

@end

@implementation AgentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUserModel:(UserModel *)userModel {
    _userModel = userModel;
    
    [self.headerImg sd_setImageWithURL:[NSURL URLWithString:userModel.header] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    
    self.nameLab.text = userModel.userName;
    
    self.dayLab.text = [NSString stringWithFormat:SetTitle(@"Company_day"),(long)userModel.dayNumber,(long)userModel.hourNumber,(long)userModel.minuteNumber];
}
@end
