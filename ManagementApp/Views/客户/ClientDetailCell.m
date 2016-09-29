//
//  ClientDetailCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientDetailCell.h"

@interface ClientDetailCell ()

@property (nonatomic, strong) UILabel *codeLab;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *numLab;
@property (nonatomic, strong) UILabel *timeLab;

@end

@implementation ClientDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.codeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.codeLab.adjustsFontSizeToFitWidth = YES;
        self.codeLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.codeLab];
        
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.textAlignment = NSTextAlignmentRight;
        self.priceLab.adjustsFontSizeToFitWidth = YES;
        self.priceLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.priceLab];
        
        self.numLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.numLab.textAlignment = NSTextAlignmentCenter;
        self.numLab.adjustsFontSizeToFitWidth = YES;
        self.numLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.numLab];
        
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.textColor = [UIColor lightGrayColor];
        self.timeLab.adjustsFontSizeToFitWidth = YES;
        self.timeLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.timeLab];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.codeLab sizeToFit];
    [self.priceLab sizeToFit];
    [self.numLab sizeToFit];
    [self.timeLab sizeToFit];
    
    self.timeLab.frame = (CGRect){self.width-50,(self.height-self.timeLab.height)/2,40,self.timeLab.height};
    self.numLab.frame = (CGRect){self.timeLab.left-70,(self.height-self.numLab.height)/2,65,self.numLab.height};
    self.priceLab.frame = (CGRect){self.numLab.left-80,(self.height-self.priceLab.height)/2,75,self.priceLab.height};
    self.codeLab.frame = (CGRect){15,(self.height-self.codeLab.height)/2,self.priceLab.left-20,self.codeLab.height};
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.codeLab.text = @"";
    self.priceLab.text = @"";
    self.numLab.text = @"";
    self.timeLab.text = @"";
}

-(void)dealloc {
    SafeRelease(_codeLab);
    SafeRelease(_priceLab);
    SafeRelease(_numLab);
    SafeRelease(_timeLab);
}

#pragma mark -
#pragma mark - getter/setter

-(void)setOrderModel:(OrderModel *)orderModel {
    _orderModel = orderModel;
    
    self.codeLab.text = orderModel.orderCode;
    
    if (orderModel.orderStatus==0) {
        self.priceLab.textColor = [UIColor blackColor];
    }else if (orderModel.orderStatus==1) {
        self.priceLab.textColor = COLOR(252, 166, 0, 1);
    }else {
        self.priceLab.textColor = COLOR(25, 216, 120, 1);
    }
    
    self.priceLab.text = [NSString stringWithFormat:@"%.2f",orderModel.orderPrice];
    self.numLab.text = [NSString stringWithFormat:@"%d",(int)orderModel.orderCount];
    self.timeLab.text = orderModel.timeStr;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
