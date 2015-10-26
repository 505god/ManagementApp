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
    
    self.priceLab.text = [NSString stringWithFormat:@"%.2f",clientModel.totalPrice];
    
    if (clientModel.clientType==0) {
        self.imgViewLeftConstraint.constant = 10;
    }else {
        self.imgViewLeftConstraint.constant = -27;
        self.clientImg.hidden = YES;
    }
}


-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.nameLab.text = @"";
    self.priceLab.text = @"";
}
@end
