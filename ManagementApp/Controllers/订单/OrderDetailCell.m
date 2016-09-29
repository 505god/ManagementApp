//
//  OrderDetailCell.m
//  BApp
//
//  Created by 邱成西 on 16/1/12.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "OrderDetailCell.h"

#import "UIImageView+WebCache.h"

@interface OrderDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *picImg;
@property (weak, nonatomic) IBOutlet UILabel *codeLab;
@property (weak, nonatomic) IBOutlet UILabel *colorNameLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;



@end

@implementation OrderDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOrderStockModel:(OrderStockModel *)orderStockModel {
    _orderStockModel = orderStockModel;
    
    [self.picImg sd_setImageWithURL:[NSURL URLWithString:orderStockModel.header] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    
    self.codeLab.text = orderStockModel.pcode;
    
    self.colorNameLab.text = orderStockModel.colorName;
    
    self.priceLab.text = [NSString stringWithFormat:@"%.2f",orderStockModel.price];
    
    self.countLab.text = [NSString stringWithFormat:@"%ld",orderStockModel.num];
}
@end
