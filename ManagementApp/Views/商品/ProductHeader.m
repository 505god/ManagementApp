//
//  ProductHeader.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/21.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductHeader.h"

@interface ProductHeader ()

@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *saleLab;
@property (nonatomic, strong) UILabel *stockLab;

@property (nonatomic, strong) UIImageView *lineImg;
@end

@implementation ProductHeader


- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.backgroundColor = [UIColor clearColor];
        self.priceLab.font = [UIFont systemFontOfSize:14];
        self.priceLab.textColor = [UIColor lightGrayColor];
        self.priceLab.text = SetTitle(@"price");
        [self addSubview:self.priceLab];
        
        self.saleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.saleLab.backgroundColor = [UIColor clearColor];
        self.saleLab.font = [UIFont systemFontOfSize:14];
        self.saleLab.textColor = [UIColor lightGrayColor];
        self.saleLab.text = SetTitle(@"product_sale");
        [self addSubview:self.saleLab];
        
        self.stockLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.stockLab.backgroundColor = [UIColor clearColor];
        self.stockLab.text = SetTitle(@"stock");
        self.stockLab.font = [UIFont systemFontOfSize:14];
        self.stockLab.textColor = [UIColor lightGrayColor];
        [self addSubview:self.stockLab];
        
        self.lineImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg];
    }
    return self;
}

-(void)setType:(NSInteger)type {
    _type = type;
    
    if (type==0) {
        [self.saleLab setHidden:YES];
    }else {
        [self.saleLab setHidden:NO];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.priceLab sizeToFit];
    [self.saleLab sizeToFit];
    [self.stockLab sizeToFit];
    
    self.priceLab.frame = (CGRect){83,(self.height-self.priceLab.height)/2,self.priceLab.width,self.priceLab.height};
    
    self.stockLab.frame = (CGRect){self.width-10-self.stockLab.width,(self.height-self.stockLab.height)/2,self.stockLab.width,self.stockLab.height};
    
    self.saleLab.frame = (CGRect){self.stockLab.left-40-self.saleLab.width,(self.height-self.saleLab.height)/2,self.saleLab.width,self.saleLab.height};
    
    self.lineImg.frame = (CGRect){0,self.height-1,self.width,1};
}
@end
