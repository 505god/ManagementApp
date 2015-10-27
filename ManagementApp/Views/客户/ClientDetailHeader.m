//
//  ClientDetailHeader.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientDetailHeader.h"
#import "RFSegmentView.h"

@interface ClientDetailHeader ()<RFSegmentViewDelegate>

@property (nonatomic, strong) UIControl *customControl;

///等级
@property (nonatomic, strong) UIImageView *levelImg;

///名称
@property (nonatomic, strong) UILabel *nameLab;

///私密客户
@property (nonatomic, strong) UIImageView *privateImg;
@property (nonatomic, strong) UILabel *privateLab;
@property (nonatomic, strong) UIImageView *arrowImg;

@property (nonatomic, strong) RFSegmentView* segmentView;


@property (nonatomic, strong) UIImageView *lineImg;
@property (nonatomic, strong) UIImageView *lineImg2;
@property (nonatomic, strong) UIImageView *lineImg3;

///标题
@property (nonatomic, strong) UILabel *codeLab;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *numLab;
@property (nonatomic, strong) UILabel *timeLab;
@end

@implementation ClientDetailHeader
- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.customControl = [[UIControl alloc]initWithFrame:CGRectZero];
        self.customControl.backgroundColor = [UIColor whiteColor];
        [self.customControl addTarget:self action:@selector(showPrivateClient) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.customControl];
        
        ///图片
        self.levelImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.levelImg];
        
        ///名称
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.nameLab.font = [UIFont systemFontOfSize:20];
        [self addSubview:self.nameLab];
    
        ///line
        self.lineImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg];
        
        ///私密客户
        self.privateImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.privateImg];

        self.privateLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.privateLab.textColor = [UIColor lightGrayColor];
        self.privateLab.font = [UIFont systemFontOfSize:14];
        self.privateLab.text = SetTitle(@"private_client");
        [self addSubview:self.privateLab];
        
        self.arrowImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.arrowImg.image = [Utility getImgWithImageName:@"arrow_r@2x"];
        [self addSubview:self.arrowImg];
        
        ///SegmentView
        self.segmentView = [[RFSegmentView alloc] initWithFrame:CGRectZero items:@[SetTitle(@"order_buy"),SetTitle(@"client_detail")]];
        self.segmentView.tintColor       = COLOR(80, 80, 80, 1);
        self.segmentView.delegate        = self;
        self.segmentView.selectedIndex   = 0;
        [self addSubview:self.segmentView];
        
        ///line2
        self.lineImg2 = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg2.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        [self addSubview:self.lineImg2];
        
        
        self.codeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.codeLab.backgroundColor = [UIColor clearColor];
        self.codeLab.font = [UIFont systemFontOfSize:14];
        self.codeLab.textColor = [UIColor lightGrayColor];
        self.codeLab.text = SetTitle(@"Order_code");
        [self addSubview:self.codeLab];
        
        
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.backgroundColor = [UIColor clearColor];
        self.priceLab.font = [UIFont systemFontOfSize:14];
        self.priceLab.textColor = [UIColor lightGrayColor];
        self.priceLab.textAlignment = NSTextAlignmentRight;
        self.priceLab.text = SetTitle(@"total_price");
        [self addSubview:self.priceLab];
        
        self.numLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.numLab.backgroundColor = [UIColor clearColor];
        self.numLab.font = [UIFont systemFontOfSize:14];
        self.numLab.textAlignment = NSTextAlignmentRight;
        self.numLab.textColor = [UIColor lightGrayColor];
        self.numLab.text = SetTitle(@"total_num");
        [self addSubview:self.numLab];
        
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.timeLab.backgroundColor = [UIColor clearColor];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.font = [UIFont systemFontOfSize:14];
        self.timeLab.textColor = [UIColor lightGrayColor];
        self.timeLab.text = SetTitle(@"date");
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
    
    self.customControl.frame = (CGRect){0,0,self.width,self.height};
    
    ///图片
    self.levelImg.frame = (CGRect){10,10,80,80};
    
    ///名称
    [self.nameLab sizeToFit];
    self.nameLab.frame = (CGRect){self.levelImg.right+15,10+(26-self.nameLab.height)/2,self.nameLab.width,self.nameLab.height};
    
    ///line1
    self.lineImg.frame = (CGRect){self.levelImg.right+15,36+5,self.width-25-self.levelImg.right,1};
    
    ///私密客户
    self.privateImg.frame = (CGRect){self.levelImg.right+15,self.lineImg.bottom+5,15,15};
    
    [self.privateLab sizeToFit];
    self.privateLab.frame = (CGRect){self.privateImg.right+5,self.lineImg.bottom+5,self.privateLab.width,self.privateLab.height};
    
    self.arrowImg .frame = (CGRect){self.width-50,self.lineImg.bottom+5,40,40};
    
    ///SegmentView
    self.segmentView.frame = (CGRect){10,self.levelImg.bottom+10,self.width-20,40};
    
    ///line2
    self.lineImg2.frame = (CGRect){0,self.segmentView.bottom+5,self.width,1};
    
    ///标题
    if (self.selectedIndex==0) {
        [self.codeLab sizeToFit];
        self.codeLab.frame = (CGRect){10,self.lineImg2.bottom+5,120,self.codeLab.height};
        
        [self.timeLab sizeToFit];
        self.timeLab.frame = (CGRect){self.width-60,self.lineImg2.bottom+5,50,self.timeLab.height};
        
        [self.numLab sizeToFit];
        self.numLab.frame = (CGRect){self.timeLab.left-80,self.lineImg2.bottom+5,70,self.numLab.height};
        
        [self.priceLab sizeToFit];
        self.priceLab.frame = (CGRect){self.numLab.left-120,self.lineImg2.bottom+5,100,self.priceLab.height};
        
        ///line3
        self.lineImg3.frame = (CGRect){0,self.height-0.5,self.width,1};
    }
}

+(CGFloat)returnHeightWithIndex:(NSInteger)index {
    CGFloat height = 0;
    
    if (index==0){
        height = 10 + 80 +10 +45.5 + 28;
    }else {
        height = 10 + 80 +10 +45.5;
    }
    
    return height;
}

-(void)dealloc {
    SafeRelease(_customControl);
    SafeRelease(_levelImg);
    SafeRelease(_nameLab);
    SafeRelease(_privateImg);
    SafeRelease(_privateLab);
    SafeRelease(_lineImg);
    SafeRelease(_lineImg2);
    SafeRelease(_arrowImg);
    SafeRelease(_codeLab);
    SafeRelease(_segmentView);
    SafeRelease(_priceLab);
    SafeRelease(_lineImg3);
    SafeRelease(_numLab);
    SafeRelease(_timeLab);
}

#pragma mark -
#pragma mark - getter/setter

-(void)setClientModel:(ClientModel *)clientModel {
    _clientModel = clientModel;
    
    self.levelImg.image = [Utility getImgWithImageName:[NSString stringWithFormat:@"charc_%d_80@2x",(int)clientModel.clientLevel+1]];
    
    self.nameLab.text = clientModel.clientName;
    
    if (clientModel.isPrivate) {
        self.privateImg.image = [Utility getImgWithImageName:@"premium_flag@2x"];
        self.customControl.userInteractionEnabled = YES;
    }else {
        self.privateImg.image = [Utility getImgWithImageName:@"premium_flag_un@2x"];
        self.customControl.userInteractionEnabled = NO;
    }
    
    self.arrowImg.hidden = !clientModel.isPrivate;
}

-(void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    self.segmentView.selectedIndex  = selectedIndex;
    
    
    if (selectedIndex==0){
        self.codeLab.hidden = NO;
        self.priceLab.hidden = NO;
        self.numLab.hidden = NO;
        self.timeLab.hidden = NO;
        self.lineImg3.hidden = NO;
    }else if (selectedIndex==1) {
        self.codeLab.hidden = YES;
        self.priceLab.hidden = YES;
        self.numLab.hidden = YES;
        self.timeLab.hidden = YES;
        self.lineImg3.hidden = YES;
    }
}

#pragma mark - segmentView代理

- (void)segmentViewDidSelected:(NSUInteger)index {
    if (self.segmentChange) {
        self.segmentChange(index);
    }
}

-(void)showPrivateClient {
    if (self.showPrivate) {
        self.showPrivate(self.clientModel);
    }
}
@end
