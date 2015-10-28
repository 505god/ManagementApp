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
        self.codeLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.codeLab];
        
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.backgroundColor = [UIColor clearColor];
        self.priceLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.priceLab];
        
        self.numLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.numLab.backgroundColor = [UIColor clearColor];
        self.numLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.numLab];
        
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.timeLab.backgroundColor = [UIColor clearColor];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLab];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.codeLab sizeToFit];
    self.codeLab.frame = (CGRect){15,(self.height-self.codeLab.height)/2,120,self.codeLab.height};
    
    [self.priceLab sizeToFit];
    [self.numLab sizeToFit];
    [self.timeLab sizeToFit];
    
    self.timeLab.frame = (CGRect){self.width-60,(self.height-self.timeLab.height)/2,50,self.timeLab.height};
    self.numLab.frame = (CGRect){self.timeLab.left-80,(self.height-self.numLab.height)/2,70,self.numLab.height};
    self.priceLab.frame = (CGRect){self.numLab.left-120,(self.height-self.priceLab.height)/2,100,self.priceLab.height};
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

-(void)setClientDetailModel:(ClientDetailModel *)clientDetailModel {
    _clientDetailModel = clientDetailModel;
    
    self.codeLab.text = clientDetailModel.clientDetailCode;
    self.priceLab.text = [NSString stringWithFormat:@"%.2f",clientDetailModel.totalPrice];
    self.numLab.text = [NSString stringWithFormat:@"%d",(int)clientDetailModel.totalNum];
    self.timeLab.text = clientDetailModel.time;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
