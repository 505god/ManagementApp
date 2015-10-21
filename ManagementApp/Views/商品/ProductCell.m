//
//  ProductCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/21.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductCell.h"
#import "UIImageView+WebCache.h"

#define TableViewCellNotificationEnableScroll @"TableViewCellNotificationEnableScroll"
#define TableViewCellNotificationUnenableScroll @"TableViewCellNotificationUnenableScroll"

#import "BlockAlertView.h"

///正在修改的cell
static ProductCell *_editingCell;

@interface ProductCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *hotBtn;
@property (nonatomic, strong) UIButton *saleBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
///货号
@property (nonatomic, strong) UILabel *proCode;
///价格
@property (nonatomic, strong) UILabel *proPrice;
///销量
@property (nonatomic, strong) UILabel *proSale;
///库存
@property (nonatomic, strong) UILabel *proStock;
///热卖
@property (nonatomic, strong) UIImageView *saleImg;

@property (nonatomic, strong) UIImageView *picImg;
@property (nonatomic, strong) UIImageView *lineImg;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint startingPoint;
@end

@implementation ProductCell

-(void)dealloc {
    SafeRelease(_proCode);
    SafeRelease(_proPrice);
    SafeRelease(_proSale);
    SafeRelease(_proStock);
    SafeRelease(_saleImg);
    SafeRelease(_productModel);
    SafeRelease(_idxPath);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(NSInteger)type inTableView:(UITableView *)tableView{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.type = type;
        self.tableView=tableView;
        
        self.topView = [[UIView alloc]initWithFrame:CGRectZero];
        self.topView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.topView];
        
        UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapGesture:)];
        [self.topView addGestureRecognizer:tapGesture];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
        _panGestureRecognizer.delegate = self;
        [self.topView addGestureRecognizer:_panGestureRecognizer];
        
        
        self.proCode = [[UILabel alloc]initWithFrame:CGRectZero];
        self.proPrice = [[UILabel alloc]initWithFrame:CGRectZero];
        self.proPrice.textColor = [UIColor lightGrayColor];
        self.proPrice.font = [UIFont systemFontOfSize:15];
        
        self.proSale = [[UILabel alloc]initWithFrame:CGRectZero];
        self.proSale.textAlignment = NSTextAlignmentCenter;
        self.proSale.textColor = COLOR(25, 216, 120, 1);
        
        self.proStock = [[UILabel alloc]initWithFrame:CGRectZero];
        self.saleImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.saleImg.image = [Utility getImgWithImageName:@"sale_tag@2x"];
        self.saleImg.hidden = YES;
        
        
        self.lineImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg.image = [Utility getImgWithImageName:@"Rectangle210@2x"];
        
        self.picImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.picImg.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.topView addSubview:self.picImg];
        [self.topView addSubview:self.proCode];
        [self.topView addSubview:self.proPrice];
        [self.topView addSubview:self.proSale];
        [self.topView addSubview:self.proStock];
        [self.topView addSubview:self.saleImg];
        [self.topView addSubview:self.lineImg];
        
        self.hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.hotBtn.backgroundColor = COLOR(81, 81, 81, 81);
        self.hotBtn.hidden = YES;
        [self.hotBtn addTarget:self action:@selector(hotBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView insertSubview:self.hotBtn belowSubview:self.topView];
        
        self.saleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.saleBtn.backgroundColor = COLOR(81, 81, 81, 81);
        self.saleBtn.hidden = YES;
        [self.saleBtn addTarget:self action:@selector(saleBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView insertSubview:self.saleBtn belowSubview:self.topView];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.backgroundColor = COLOR(81, 81, 81, 81);
        self.deleteBtn.hidden = YES;
        [self.deleteBtn addTarget:self action:@selector(deleteBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn setImage:[Utility getImgWithImageName:@"delete_bt@2x"] forState:UIControlStateNormal];
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.topView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUnenableScroll:) name:TableViewCellNotificationUnenableScroll object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEnableScroll:) name:TableViewCellNotificationEnableScroll object:nil];
    }
    return self;
}

-(void)hotBtnTap {
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.state = CellStateUnexpanded;
    } completion:^(BOOL finished) {
        if (weakSelf.hotChange) {
            weakSelf.hotChange(weakSelf.productModel,weakSelf.idxPath);
        }
    }];
}

-(void)saleBtnTap {
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.state = CellStateUnexpanded;
    } completion:^(BOOL finished) {
        if (weakSelf.saleChange) {
            weakSelf.saleChange(weakSelf.productModel,weakSelf.idxPath);
        }
    }];
}

-(void)deleteBtnTap {
    
    __weak __typeof(self)weakSelf = self;
    BlockAlertView *alert = [BlockAlertView alertWithTitle:SetTitle(@"ConfirmDelete") message:nil];
    [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
        
    }];
    [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
        [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.state = CellStateUnexpanded;
        } completion:^(BOOL finished) {
            if (weakSelf.deleteCell) {
                weakSelf.deleteCell(weakSelf.idxPath);
            }
        }];
    }];
    [alert show];
}


-(void)setProductModel:(ProductModel *)productModel {
    _productModel = productModel;
    
    self.proCode.text = productModel.productCode;
    
    self.proPrice.text = @"";
    if (productModel.productPriceModel && productModel.productPriceModel.selected==0) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.productPriceModel.aPrice];
    }else if (productModel.productPriceModel && productModel.productPriceModel.selected==1) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.productPriceModel.bPrice];
    }else if (productModel.productPriceModel && productModel.productPriceModel.selected==2) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.productPriceModel.cPrice];
    }else if (productModel.productPriceModel && productModel.productPriceModel.selected==3) {
        self.proPrice.text = [NSString stringWithFormat:@"%.2f",productModel.productPriceModel.dPrice];
    }
    
    if (self.type==0) {
        self.proSale.text = @"";
        self.proStock.textColor = [UIColor blackColor];
    }else {
        self.proSale.text = [NSString stringWithFormat:@"%d",(int)productModel.saleCount];
        self.proStock.textColor = COLOR(252, 166, 0, 1);
    }
    
    self.proStock.text = [NSString stringWithFormat:@"%d",(int)productModel.stockCount];
    
    self.saleImg.hidden = !productModel.isHot;
    
    [self.picImg sd_setImageWithURL:[NSURL URLWithString:productModel.picHeader] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    
    [self.hotBtn setImage:[Utility getImgWithImageName:productModel.isHot?@"hot_bt@2x":@"hot_s_bt@2x"] forState:UIControlStateNormal];
    [self.saleBtn setImage:[Utility getImgWithImageName:productModel.isDisplay?@"hide_bt@2x":@"hide_s_bt@2x"] forState:UIControlStateNormal];
}

-(void)setIdxPath:(NSIndexPath *)idxPath {
    _idxPath = idxPath;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.proCode.text = @"";
    self.proPrice.text = @"";
    self.proSale.text = @"";
    self.proStock.text = @"";
    self.saleImg.hidden = YES;
    self.picImg.image = nil;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.topView.frame = (CGRect){0,0,self.width,self.height};
    
    self.saleImg.frame = (CGRect){0,0,3,self.height};
    
    self.picImg.frame = (CGRect){self.saleImg.right+10,5,60,60};
    
    [self.proCode sizeToFit];
    [self.proPrice sizeToFit];
    
    self.proCode.frame = (CGRect){self.picImg.right+10,(self.height-self.proCode.height-self.proPrice.height-5)/2,self.proCode.width,self.proCode.height};
    self.proPrice.frame = (CGRect){self.picImg.right+10,self.proCode.bottom+5,self.proPrice.width,self.proPrice.height};
    
    [self.proStock sizeToFit];
    self.proStock.frame = (CGRect){self.width-self.proStock.width-10,(self.height-self.proStock.height)/2,self.proStock.width,self.proStock.height};
    
    ///库存标题的宽度
    NSDictionary *fontDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGRect rect = [SetTitle(@"stock") boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:fontDic context:nil];
    
    [self.proSale sizeToFit];
    self.proSale.frame = (CGRect){(self.width-10-rect.size.width)-40-self.proSale.width,(self.height-self.proSale.height)/2,self.proSale.width,self.proSale.height};
    
    self.lineImg.frame = (CGRect){self.picImg.left,self.height-1,self.width-self.picImg.left,1};
    
    
    
    self.deleteBtn.frame = (CGRect){self.width-60,0,60,self.height};
    self.saleBtn.frame = (CGRect){self.deleteBtn.left-60,0,60,self.height};
    self.hotBtn.frame = (CGRect){self.saleBtn.left-60,0,60,self.height};
}


- (void)panHandler:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.startingPoint = self.topView.frame.origin;
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            CGFloat currentX = [recognizer translationInView:self].x;
            CGFloat newXOffset = self.startingPoint.x + currentX;
            if (currentX>0) {
            }else {
                self.hotBtn.hidden= NO;
                self.saleBtn.hidden= NO;
                self.deleteBtn.hidden= NO;
                if (fabs(currentX)<=180) {
                    self.topView.frame = CGRectMake(newXOffset, self.startingPoint.y, CGRectGetWidth(self.topView.frame), CGRectGetHeight(self.topView.frame));
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            CGFloat currentX = self.topView.frame.origin.x;
            __weak __typeof(self)weakSelf = self;
            if (fabs(currentX) > 90) {
                self.state = CellStateExpanded;
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    weakSelf.topView.frame = CGRectMake(-180, weakSelf.startingPoint.y, CGRectGetWidth(weakSelf.topView.frame), CGRectGetHeight(weakSelf.topView.frame));
                } completion:nil];
                
            }else {
                self.state = CellStateUnexpanded;
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    weakSelf.topView.frame = CGRectMake(0, weakSelf.startingPoint.y, CGRectGetWidth(weakSelf.topView.frame), CGRectGetHeight(weakSelf.topView.frame));
                } completion:nil];
                self.hotBtn.hidden= YES;
                self.saleBtn.hidden= YES;
                self.deleteBtn.hidden= YES;
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)onTapGesture:(UITapGestureRecognizer*)recognizer{
    if (_editingCell){
        _editingCell.state=CellStateUnexpanded;
    }
    else{
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:self];
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:cellIndexPath];
        }
    }
}

-(void)setState:(TableViewCellState)state{
    _state=state;
    if (state==CellStateExpanded) {
        self.tableView.scrollEnabled=NO;
        self.tableView.allowsSelection=NO;
        _editingCell=self;
        ///通知所有的cell停止滚动(除自己这个)
        [[NSNotificationCenter defaultCenter] postNotificationName:TableViewCellNotificationUnenableScroll object:nil];
    }else if(state==CellStateUnexpanded) {
        ///为了不让快速按下时鼓动状态固定在一半，一开始就先停止触摸
        self.tableView.userInteractionEnabled=NO;
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.tableView.userInteractionEnabled=YES;
        });
        
        __weak __typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.topView.frame = CGRectMake(0, 0, CGRectGetWidth(weakSelf.topView.frame), CGRectGetHeight(weakSelf.topView.frame));
        } completion:nil];
        
        ///tableView可以滚动了
        _editingCell=nil;
        self.tableView.scrollEnabled=YES;
        self.tableView.allowsSelection=YES;
        ///通知所有的cell可以滚动
        [[NSNotificationCenter defaultCenter] postNotificationName:TableViewCellNotificationEnableScroll object:nil];
    }
}


///内部通知所有的cell可以滚动scrollView了
-(void)notificationEnableScroll:(NSNotification*)notification{
    [self.topView addGestureRecognizer:_panGestureRecognizer];
}
///内部通知所有的cell不可以滚动scrollView(除当前编辑的这个外)
-(void)notificationUnenableScroll:(NSNotification*)notification{
    if (_editingCell!=self)
        [self.topView removeGestureRecognizer:_panGestureRecognizer];
    
}
@end
