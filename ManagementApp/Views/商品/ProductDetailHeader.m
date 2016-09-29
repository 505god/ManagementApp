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
#import "UIImageView+Addition.h"

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
@property (nonatomic, strong) UIImageView *lineImg2;
@property (nonatomic, strong) UIImageView *lineImg3;
///盈利状况
@property (nonatomic, strong) UIButton *profitBtn;
@property (nonatomic, strong) UILabel *profitLab;

@property (nonatomic, strong) RFSegmentView* segmentView;

@property (nonatomic, strong) UIView *customView;

///标题
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *saleLab;
@property (nonatomic, strong) UILabel *timeLab;
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
        self.profitBtn.hidden = YES;
        [self.profitBtn addTarget:self action:@selector(showProfitDetail) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.profitBtn];
        
        self.profitLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.profitLab.textColor = [UIColor whiteColor];
        [self.profitBtn addSubview:self.profitLab];
        
        ///图片
        self.picImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.picImg.contentMode = UIViewContentModeScaleAspectFill;
        self.picImg.clipsToBounds = YES;
        [self.picImg addDetailShow];
        [self addSubview:self.picImg];
        
        ///货号
        self.proCode = [[UILabel alloc]initWithFrame:CGRectZero];
        self.proCode.font = [UIFont systemFontOfSize:20];
        [self addSubview:self.proCode];
        
        ///热卖
        self.saleImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.saleImg.image = [Utility getImgWithImageName:@"sale_tag_l@2x"];
        self.saleImg.hidden = YES;
        [self addSubview:self.saleImg];
        
        ///line
        self.lineImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg];
        
        ///分类
        self.proSort = [[UILabel alloc]initWithFrame:CGRectZero];
        self.proSort.textColor = [UIColor lightGrayColor];
        [self addSubview:self.proSort];
        
        ///价格
        self.proPrice = [[UILabel alloc]initWithFrame:CGRectZero];
        self.proPrice.textColor = [UIColor lightGrayColor];
        self.proPrice.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.proPrice];
        
        ///SegmentView
        self.segmentView = [[RFSegmentView alloc] initWithFrame:CGRectZero items:@[SetTitle(@"pro_sale"),SetTitle(@"client_buy"),SetTitle(@"stock_num")]];
        self.segmentView.tintColor       = COLOR(80, 80, 80, 1);
        self.segmentView.delegate        = self;
        self.segmentView.selectedIndex   = 0;
        [self addSubview:self.segmentView];
        
        ///line2
        self.lineImg2 = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg2.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg2];
        
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.titleLab.backgroundColor = [UIColor clearColor];
        self.titleLab.font = [UIFont systemFontOfSize:14];
        self.titleLab.textColor = [UIColor lightGrayColor];
        [self addSubview:self.titleLab];
        
        
        self.label = [[UILabel alloc]initWithFrame:CGRectZero];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont systemFontOfSize:14];
        self.label.textColor = [UIColor lightGrayColor];
        self.label.textAlignment = NSTextAlignmentRight;
        self.label.text = SetTitle(@"price");
        [self addSubview:self.label];
        
        self.saleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.saleLab.backgroundColor = [UIColor clearColor];
        self.saleLab.font = [UIFont systemFontOfSize:14];
        self.saleLab.textAlignment = NSTextAlignmentCenter;
        self.saleLab.textColor = [UIColor lightGrayColor];
        self.saleLab.text = SetTitle(@"product_sale");
        [self addSubview:self.saleLab];
        
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.timeLab.backgroundColor = [UIColor clearColor];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.font = [UIFont systemFontOfSize:14];
        self.timeLab.textColor = [UIColor lightGrayColor];
        [self addSubview:self.timeLab];
        
        ///line3
        self.lineImg3 = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg3.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg3];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.customView.frame = (CGRect){0,0,self.width,self.height};
    
    CGFloat originY = 0;
    
    ///盈利状况
    if (self.productModel.profitStatus == -1) {
        originY += 10;
    }else {
        self.profitBtn.frame = (CGRect){0,originY,self.width,60};
        originY += 70;
        
        [self.profitLab sizeToFit];
        self.profitLab.frame = (CGRect){self.width-self.profitLab.width-40,(60-self.profitLab.height)/2,self.profitLab.width,self.profitLab.height};
    }
    
    ///图片
    self.picImg.frame = (CGRect){10,originY,80,80};
    
    ///货号
    [self.proCode sizeToFit];
    self.proCode.frame = (CGRect){self.picImg.right+15,originY+(26-self.proCode.height)/2,self.proCode.width,self.proCode.height};
    
    ///热卖
    self.saleImg.frame = (CGRect){self.width-10-26,originY,26,26};
    
    ///line1
    self.lineImg.frame = (CGRect){self.picImg.right+15,self.saleImg.bottom+5,self.width-25-self.picImg.right,1};
    
    ///分类
    [self.proSort sizeToFit];
    self.proSort.frame = (CGRect){self.picImg.right+15,self.lineImg.bottom+5,self.lineImg.width,self.proSort.height};
    
    ///价格
    [self.proPrice sizeToFit];
    self.proPrice.frame = (CGRect){self.picImg.right+15,self.proSort.bottom+5,self.lineImg.width,self.proPrice.height};
    
    ///SegmentView
    self.segmentView.frame = (CGRect){10,self.picImg.bottom+10,self.width-20,40};
    
    ///line2
    self.lineImg2.frame = (CGRect){0,self.segmentView.bottom+5,self.width,1};
    
    
    ///标题
    if (self.selectedIndex==0){
        [self.timeLab sizeToFit];/////50
        self.timeLab.frame = (CGRect){self.width-60,self.lineImg2.bottom+5,50,self.timeLab.height};
        
        [self.saleLab sizeToFit];/////60
        self.saleLab.frame = (CGRect){self.timeLab.left-100,self.timeLab.top,90,self.saleLab.height};
        
        [self.label sizeToFit];////100
        self.label.frame = (CGRect){self.saleLab.left-120,self.timeLab.top,110,self.label.height};
        
        [self.titleLab sizeToFit];
        self.titleLab.frame = (CGRect){15,self.timeLab.top,self.label.left-25,self.titleLab.height};
    }else if (self.selectedIndex==1) {
        [self.timeLab sizeToFit];/////50
        self.timeLab.frame = (CGRect){self.width-80,self.lineImg2.bottom+5,70,self.timeLab.height};
        
        [self.saleLab sizeToFit];/////60
        self.saleLab.frame = (CGRect){self.timeLab.left-100,self.timeLab.top,90,self.saleLab.height};

        [self.titleLab sizeToFit];
        self.titleLab.frame = (CGRect){15,self.timeLab.top,self.saleLab.left-25,self.titleLab.height};
    }else {
        [self.timeLab sizeToFit];/////50
        self.timeLab.frame = (CGRect){self.width-80,self.lineImg2.bottom+5,70,self.timeLab.height};
        
        [self.saleLab sizeToFit];/////60
        self.saleLab.frame = (CGRect){self.timeLab.left-100,self.timeLab.top,90,self.saleLab.height};
        
        [self.titleLab sizeToFit];
        self.titleLab.frame = (CGRect){65,self.timeLab.top,self.saleLab.left-65,self.titleLab.height};
    }
    
    ///line3
    self.lineImg3.frame = (CGRect){0,self.height-0.5,self.width,1};
}

+(CGFloat)returnHeightWithProductModel:(ProductModel *)productModel {
    CGFloat height = 0;
    
    if (productModel.profitStatus == -1){
        height+=10;
    }else {
        height+=70;
    }
    
    height+=80;
    height+=10;
    height+=50;
    height+=10;
    height+=15;
    
    return height;
}

-(void)dealloc {
    SafeRelease(_proCode);
    SafeRelease(_proPrice);
    SafeRelease(_proSort);
    SafeRelease(_saleImg);
    SafeRelease(_picImg);
    SafeRelease(_lineImg);
    SafeRelease(_lineImg2);
    SafeRelease(_profitBtn);
    SafeRelease(_profitLab);
    SafeRelease(_segmentView);
    SafeRelease(_customView);
    SafeRelease(_lineImg3);
    SafeRelease(_titleLab);
    SafeRelease(_label);
    SafeRelease(_saleLab);
    SafeRelease(_timeLab);
}

#pragma mark - 
#pragma mark - getter/setter

-(void)setProductModel:(ProductModel *)productModel {
    _productModel = productModel;
    
    ///盈利状况
    self.profitBtn.hidden = NO;
    if (productModel.profitStatus == -1) {
        self.profitBtn.hidden = YES;
    }else if (productModel.profitStatus == 0) {
        UIImage *normalImg = [Utility getImgWithImageName:@"profit_down@2x"];
        normalImg = [normalImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 80, 10, 80)];
        
        [self.profitBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    }else if (productModel.profitStatus == 1) {
        UIImage *normalImg = [Utility getImgWithImageName:@"profit_up@2x"];
        normalImg = [normalImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 80, 10, 80)];
        [self.profitBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    }
    self.profitLab.text = [NSString stringWithFormat:@"%.2f",productModel.profit];
    
    ///图片
    if (productModel.isDisplay) {
        [self.picImg sd_setImageWithURL:[NSURL URLWithString:productModel.picHeader] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    }else {
        [self.picImg gay_sd_setImageWithURL:[NSURL URLWithString:productModel.picHeader] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    }
    
    
    
    ///货号
    self.proCode.text = [NSString stringWithFormat:@"%@:%@",productModel.productCode,productModel.productName];
    
    ///热卖
    self.saleImg.hidden = !productModel.isHot;
    
    ///分类
    self.proSort.text = productModel.sortModel.sortName;
    
    ///价格
    if (productModel.selected==1) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.bPrice];
    }else if (productModel.selected==2) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.cPrice];
    }else if (productModel.selected==3) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.dPrice];
    }else {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.aPrice];
    }
}

-(void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    self.segmentView.selectedIndex  = selectedIndex;
    

    self.label.hidden = NO;
    self.saleLab.hidden = NO;
    self.timeLab.hidden = NO;
    
    if (selectedIndex==0){
        self.titleLab.text = SetTitle(@"color");
        self.timeLab.text = SetTitle(@"date");
    }else if (selectedIndex==1) {
        self.titleLab.text = SetTitle(@"navicon_client");
        self.label.hidden = YES;
        self.timeLab.text = SetTitle(@"date");
    }else {
        self.titleLab.text = SetTitle(@"color");
        self.label.hidden = YES;
        self.timeLab.text = SetTitle(@"stock");
    }
}

#pragma mark - segmentView代理

- (void)segmentViewDidSelected:(NSUInteger)index {
    if (self.segmentChange) {
        self.segmentChange(index);
    }
}


-(void)showProfitDetail {
    if (self.showProfit) {
        self.showProfit(self.productModel);
    }
}
@end
