//
//  OrderHeaderView.m
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderHeaderView.h"

@interface OrderHeaderView()
@property (nonatomic, strong) UIView *customeView;

@property (nonatomic, strong) UIImageView *numInfo;
@property (strong, nonatomic) UILabel *numLab;

@property (strong, nonatomic) UILabel *taxInfo;
@property (strong, nonatomic) UILabel *taxLab;

@property (strong, nonatomic) UILabel *priceInfo;
@property (strong, nonatomic) UILabel *priceLab;
@end

@implementation OrderHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.customeView = [[UIView alloc]initWithFrame:CGRectZero];
        self.customeView.backgroundColor = kThemeColor;
        [self addSubview:self.customeView];
        
        self.numInfo = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.numInfo.image = [Utility getImgWithImageName:@"unselected_icon@2x"];
        [self addSubview:self.numInfo];
        
        self.numLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.numLab.textColor = [UIColor whiteColor];
        self.numLab.text = @"0";
        self.numLab.font = [UIFont systemFontOfSize:18];
        [self addSubview:self.numLab];
        
//        self.taxInfo = [[UILabel alloc]initWithFrame:CGRectZero];
//        self.taxInfo.textColor = [UIColor whiteColor];
//        self.taxInfo.font = [UIFont systemFontOfSize:16];
//        self.taxInfo.text = SetTitle(@"order_tax");
//        [self addSubview:self.taxInfo];
        
//        self.taxLab = [[UILabel alloc]initWithFrame:CGRectZero];
//        self.taxLab.textColor = [UIColor whiteColor];
//        self.taxLab.textAlignment = NSTextAlignmentRight;
//        self.taxLab.text = @"0";
//        self.taxLab.font = [UIFont systemFontOfSize:18];
//        [self addSubview:self.taxLab];
        
        self.priceInfo = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceInfo.textColor = [UIColor whiteColor];
        self.priceInfo.font = [UIFont systemFontOfSize:16];
        self.priceInfo.text = SetTitle(@"order_total");
        [self addSubview:self.priceInfo];
        
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.textColor = [UIColor whiteColor];
        self.priceLab.textAlignment = NSTextAlignmentRight;
        self.priceLab.text = @"0";
        self.priceLab.font = [UIFont systemFontOfSize:25];
        [self addSubview:self.priceLab];
        
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.customeView.frame = (CGRect){0,0,self.width,self.height};
    
    [self.numLab sizeToFit];
    self.numInfo.frame = (CGRect){15,10+(self.numLab.height-7)/2,7,7};
    self.numLab.frame = (CGRect){self.numInfo.right+5,10,self.numLab.width,self.numLab.height};
    
    [self.taxInfo sizeToFit];
    [self.taxLab sizeToFit];
    self.taxLab.frame = (CGRect){self.width-self.taxLab.width-10,10,self.taxLab.width,self.taxLab.height};
    self.taxInfo.frame = (CGRect){self.taxLab.left-self.taxInfo.width-5,10+(self.taxLab.height-self.taxInfo.height)/2,self.taxInfo.width,self.taxInfo.height};
    
    [self.priceInfo sizeToFit];
    [self.priceLab sizeToFit];
    self.priceInfo.frame = (CGRect){15,self.numLab.bottom+10+(self.priceLab.height-self.priceInfo.height)/2,self.priceInfo.width,self.priceInfo.height};
    self.priceLab.frame = (CGRect){self.priceInfo.right+5,self.numLab.bottom+10,self.width-self.priceInfo.right-15,self.priceLab.height};
}

-(void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    if (dataArray.count>1) {
        self.numLab.text = [NSString stringWithFormat:@"%ld",[dataArray[0] integerValue]];
        
        self.priceLab.text = [NSString stringWithFormat:@"%.2f",[dataArray[1] floatValue]];
        
        self.taxLab.text = [NSString stringWithFormat:@"%.2f",[dataArray[8] floatValue]];
    }
    
}
@end
