//
//  OrderCell.m
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderCell.h"

@interface OrderCell()

@property (weak, nonatomic) IBOutlet UIImageView *payImg;
@property (weak, nonatomic) IBOutlet UIImageView *deliverImg;

@property (weak, nonatomic) IBOutlet UILabel *codeLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;

@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;

@end


@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOrderModel:(OrderModel *)orderModel{
    _orderModel=orderModel;
    
    self.payImg.image = [Utility getImgWithImageName:[NSString stringWithFormat:@"order_money_bg_%d@2x",(int)orderModel.isPay]];
    
    self.deliverImg.image = [Utility getImgWithImageName:[NSString stringWithFormat:@"order_ship_bg_%d@2x",(int)orderModel.isDeliver]];
    
    self.codeLab.text = orderModel.orderCode;
    self.nameLab.text = orderModel.clientName;
    self.countLab.text = [NSString stringWithFormat:@"%d",(int)orderModel.orderCount];
    self.timeLab.text = orderModel.timeString;
    self.priceLab.text = [NSString stringWithFormat:@"%.2f",orderModel.orderPrice];
}

@end
