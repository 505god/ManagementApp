//
//  ProductDetailHeader.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/23.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductDetailHeader.h"
#import "UIImageView+WebCache.h"
#import "RFSegmentView.h"

@interface ProductDetailHeader ()<RFSegmentViewDelegate>
///货号
@property (nonatomic, strong) UILabel *proCode;
///价格
@property (nonatomic, strong) UILabel *proPrice;
///分类
@property (nonatomic, strong) UILabel *proSort;

///热卖
@property (nonatomic, strong) UIImageView *saleImg;
///图片
@property (nonatomic, strong) UIImageView *picImg;

@property (nonatomic, strong) UIImageView *lineImg;

///盈利状况
@property (nonatomic, strong) UIButton *profitBtn;
@property (nonatomic, strong) UILabel *profitLab;

@property (nonatomic, strong) RFSegmentView* segmentView;

@property (nonatomic, strong) UIView *customView;

@end

@implementation ProductDetailHeader

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.customView = [[UIView alloc]initWithFrame:CGRectZero];
        self.customView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.customView];
        
        ///盈利状况
        self.profitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.profitBtn setBackgroundImage:[Utility getImgWithImageName:@"profit_down@2x"] forState:UIControlStateNormal];
        [self addSubview:self.profitBtn];
        
        
        self.lineImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)dealloc {
    SafeRelease(_profitBtn);
}

#pragma mark - 
#pragma mark - getter/setter


@end
