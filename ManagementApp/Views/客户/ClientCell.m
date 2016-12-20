//
//  ClientCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/24.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientCell.h"

@interface ClientCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *nameLab;
@property (nonatomic, weak) IBOutlet UILabel *priceLab;
@property (nonatomic, weak) IBOutlet UIImageView *clientImg;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewLeftConstraint;
@end

@implementation ClientCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ClientCell" owner:self options: nil];
        if(arrayOfViews.count < 1){return nil;}
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[ClientCell class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        
        self.notificationHub = [[RKNotificationHub alloc]initWithView:self];
        [self.notificationHub setCount:-1];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setClientModel:(ClientModel *)clientModel {
    _clientModel = clientModel;
    
    self.imgView.image = [Utility getImgWithImageName:[NSString stringWithFormat:@"charc_%d_28@2x",(int)clientModel.clientLevel+1]];
    self.nameLab.text = clientModel.clientName;
    
    self.clientImg.hidden = !clientModel.isPrivate;
    
    if (self.type==2) {
        self.priceLab.text = [NSString stringWithFormat:@"%ld",clientModel.tradeNum];
    }else if (self.type==3) {
        self.priceLab.text = [NSString stringWithFormat:@"%.2f",clientModel.totalPrice];
    }else if (self.type==4) {
        self.priceLab.text = [NSString stringWithFormat:@"%.2f",clientModel.arrearsPrice];
    }else {
        self.priceLab.text = [NSString stringWithFormat:@"%.2f",clientModel.totalPrice];
    }
    
    
    
    if (clientModel.clientType==0) {
        self.imgViewLeftConstraint.constant = 10;
    }else {
        self.imgViewLeftConstraint.constant = -27;
        self.clientImg.hidden = YES;
        self.priceLab.text = @"";
    }
    
    if (clientModel.redPoint>0 || clientModel.msgCount>0) {
        [self.notificationHub setCount:0];
    }else {
        [self.notificationHub setCount:-1];
    }
}

//2=交易次数最多 3=交易金额最高 4=欠款最多
-(void)setType:(NSInteger)type {
    _type = type;
    
    if (type==2) {
        self.priceLab.textColor = COLOR(252, 166, 0, 1);
    }else if (type==3) {
        self.priceLab.textColor = kThemeColor;
    }else if (type==4) {
        self.priceLab.textColor = kDeleteColor;
    }else {
        self.priceLab.textColor = kThemeColor;
    }
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.nameLab.text = @"";
    self.priceLab.text = @"";
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    
    [self.notificationHub setCircleAtFrame:(CGRect){40,6,10,10}];
}
@end
