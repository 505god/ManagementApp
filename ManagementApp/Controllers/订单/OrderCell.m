//
//  OrderCell.m
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderCell.h"

@interface OrderCell()
@property (weak, nonatomic) IBOutlet UIImageView *orderMoneyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *orderShipImageView;

@end


@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOrderModel:(OrderModel*)orderModel{
    _orderModel=orderModel;
    //self.orderMoneyImageView.transform = CGAffineTransformMakeScale(1,10);
//    UIImage *image = [UIImage imageNamed:@"order_money_bg"];
  //  [self.orderMoneyImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(27, 0, 28, 0) resizingMode:UIImageResizingModeStretch];
//    [self.orderShipImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
}

@end
