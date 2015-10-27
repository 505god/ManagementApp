//
//  ProductDetailCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductDetailCell.h"
#import "UIImageView+WebCache.h"

@interface ProductDetailCell ()

@property (nonatomic, strong) UIImageView *picImg;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *saleLab;
@property (nonatomic, strong) UILabel *timeLab;

@end

@implementation ProductDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.picImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.picImg.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.picImg];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.titleLab.backgroundColor = [UIColor clearColor];
        self.titleLab.adjustsFontSizeToFitWidth = YES;
        self.titleLab.minimumScaleFactor = 12;
        [self.contentView addSubview:self.titleLab];
        
        self.label = [[UILabel alloc]initWithFrame:CGRectZero];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.label];
        
        self.saleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.saleLab.backgroundColor = [UIColor clearColor];
        self.saleLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.saleLab];
        
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.timeLab.backgroundColor = [UIColor clearColor];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLab];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.selectedIndex==0) {
        
        self.picImg.frame = (CGRect){15,(self.height-40)/2,40,40};
        
        [self.timeLab sizeToFit];/////50
        self.timeLab.frame = (CGRect){self.width-60,(self.height-self.timeLab.height)/2,50,self.timeLab.height};
        
        [self.saleLab sizeToFit];/////60
        self.saleLab.frame = (CGRect){self.timeLab.left-80,(self.height-self.saleLab.height)/2,60,self.saleLab.height};
        
        [self.label sizeToFit];////100
        self.label.frame = (CGRect){self.saleLab.left-120,(self.height-self.label.height)/2,100,self.label.height};
        
        [self.titleLab sizeToFit];
        self.titleLab.frame = (CGRect){65,(self.height-self.titleLab.height)/2,self.label.left-65,self.titleLab.height};
    }else if (self.selectedIndex==1) {
        [self.timeLab sizeToFit];/////50
        self.timeLab.frame = (CGRect){self.width-70,(self.height-self.timeLab.height)/2,60,self.timeLab.height};
        
        [self.saleLab sizeToFit];/////60
        self.saleLab.frame = (CGRect){self.timeLab.left-120,(self.height-self.saleLab.height)/2,100,self.saleLab.height};
        
        [self.titleLab sizeToFit];
        self.titleLab.frame = (CGRect){15,(self.height-self.titleLab.height)/2,self.saleLab.left-25,self.titleLab.height};
    }else if (self.selectedIndex==2) {
        self.picImg.frame = (CGRect){15,(self.height-40)/2,40,40};
        
        [self.timeLab sizeToFit];/////50
        self.timeLab.frame = (CGRect){self.width-80,(self.height-self.timeLab.height)/2,60,self.timeLab.height};
        
        [self.saleLab sizeToFit];/////60
        self.saleLab.frame = (CGRect){self.timeLab.left-80,(self.height-self.saleLab.height)/2,60,self.saleLab.height};
        
        [self.titleLab sizeToFit];
        self.titleLab.frame = (CGRect){65,(self.height-self.titleLab.height)/2,self.saleLab.left-65,self.titleLab.height};
    }
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.timeLab.text = @"";
    self.titleLab.text = @"";
    self.saleLab.text = @"";
    self.label.text = @"";
}

-(void)dealloc {
    SafeRelease(_titleLab);
    SafeRelease(_label);
    SafeRelease(_saleLab);
    SafeRelease(_timeLab);
    SafeRelease(_picImg);
}

#pragma mark -
#pragma mark - getter/setter

-(void)setProductModel:(ProductModel *)productModel {
    _productModel = productModel;
}

-(void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    self.label.hidden = NO;
    self.saleLab.hidden = NO;
    self.timeLab.hidden = NO;
    self.picImg.hidden = NO;
    if (selectedIndex==0){
    }else if (selectedIndex==1) {
        self.label.hidden = YES;
        self.picImg.hidden = YES;
    }else {
        self.label.hidden = YES;
    }
}

-(void)setProductStockModel:(ProductStockModel *)productStockModel {
    _productStockModel = productStockModel;
    
    if (self.selectedIndex==0) {
        [self.picImg sd_setImageWithURL:[NSURL URLWithString:productStockModel.picHeader] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
        
        self.titleLab.text = productStockModel.colorModel.colorName;
        
        self.saleLab.text = [NSString stringWithFormat:@"%ld",productStockModel.saleNum];
        self.timeLab.text = productStockModel.time;
    }else if (self.selectedIndex==1) {
        
        self.titleLab.text = productStockModel.clientName;
        self.saleLab.text = [NSString stringWithFormat:@"%ld",productStockModel.saleNum];
        self.timeLab.text = productStockModel.time;
    }else if (self.selectedIndex==2) {
        [self.picImg sd_setImageWithURL:[NSURL URLWithString:productStockModel.picHeader] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
        
        self.titleLab.text = productStockModel.colorModel.colorName;
        self.saleLab.text = [NSString stringWithFormat:@"%ld",productStockModel.saleNum];
        
        if (self.productModel.stockWarningModel.isSetting) {
            if (productStockModel.stockNum<self.productModel.stockWarningModel.singleNum) {
                self.timeLab.textColor = COLOR(252, 166, 0, 1);
            }else {
                self.timeLab.textColor = [UIColor blackColor];
            }
        }
        self.timeLab.text = [NSString stringWithFormat:@"%ld",productStockModel.stockNum];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
