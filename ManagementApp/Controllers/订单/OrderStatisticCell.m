//
//  OrderStatisticCell.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/18.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "OrderStatisticCell.h"


@interface OrderStatisticCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *infoLab;
@property (nonatomic, strong) UIImageView *lineView;
@end

@implementation OrderStatisticCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.titleLab.adjustsFontSizeToFitWidth = YES;
        self.titleLab.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:self.titleLab];
        
        self.infoLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.infoLab.textAlignment = NSTextAlignmentRight;
        self.infoLab.adjustsFontSizeToFitWidth = YES;
        self.infoLab.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:self.infoLab];
        
        self.lineView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineView.image = [Utility getImgWithImageName:@"line@2x"];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

-(void)setModel:(StatisticModel *)model {
    _model = model;
    
    
    self.titleLab.text = model.title;
    self.infoLab.text = model.info;
    
    if (model.type==0) {
        self.titleLab.textColor = [UIColor whiteColor];
        self.infoLab.textColor = [UIColor whiteColor];
        
        self.titleLab.font = [UIFont systemFontOfSize:18];
        self.infoLab.font = [UIFont systemFontOfSize:18];
    }else {
        self.titleLab.textColor = [UIColor lightGrayColor];
        self.infoLab.textColor = [UIColor lightGrayColor];
        
        self.titleLab.font = [UIFont systemFontOfSize:16];
        self.infoLab.font = [UIFont systemFontOfSize:16];
    }
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLab sizeToFit];
    [self.infoLab sizeToFit];
    
    if (self.model.type==0) {
        self.titleLab.frame = (CGRect){15,(self.height-self.titleLab.height)/2,self.titleLab.width,self.titleLab.height};
        
        self.lineView.frame = (CGRect){0,self.height-1,self.width,1};
    }else {
        self.titleLab.frame = (CGRect){25,(self.height-self.titleLab.height)/2,self.titleLab.width,self.titleLab.height};
        
        self.lineView.frame = (CGRect){25,self.height-1,self.width-25,1};
    }
    
    self.infoLab.frame = (CGRect){(self.width-10-self.infoLab.width),(self.height-self.infoLab.height)/2,self.infoLab.width,self.infoLab.height};
}
@end
