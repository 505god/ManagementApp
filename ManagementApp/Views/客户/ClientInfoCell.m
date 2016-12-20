//
//  ClientInfoCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientInfoCell.h"

@interface ClientInfoCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

@end

@implementation ClientInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ClientInfoCell" owner:self options: nil];
        if(arrayOfViews.count < 1){return nil;}
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[ClientInfoCell class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        
    }
    return self;
}


-(void)setIdxPath:(NSIndexPath *)idxPath {
    _idxPath = idxPath;
}

-(void)setClientModel:(ClientModel *)clientModel {
    _clientModel = clientModel;
    
    if (self.idxPath.row==0) {
        self.titleLab.text = SetTitle(@"log_phone");
        self.detailLab.text = clientModel.clientPhone?clientModel.clientPhone:@"";
    }else if (self.idxPath.row==1){
        self.titleLab.text = SetTitle(@"email");
        self.detailLab.text = clientModel.clientEmail?clientModel.clientEmail:@"";
    }else if (self.idxPath.row==2) {
        self.titleLab.text = SetTitle(@"product_mark");
        self.detailLab.text = clientModel.clientRemark?clientModel.clientRemark:@"";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
