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

@interface ProductCell ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIView *cellContentView;

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
@property (nonatomic, strong) UIImageView *profitImg;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* buttonsView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGPoint startingPoint;
@end

@implementation ProductCell

-(void)dealloc {
    SafeRelease(_hotBtn);
    SafeRelease(_saleBtn);
    SafeRelease(_deleteBtn);
    SafeRelease(_proCode);
    SafeRelease(_proPrice);
    SafeRelease(_proSale);
    SafeRelease(_proStock);
    SafeRelease(_saleImg);
    SafeRelease(_productModel);
    SafeRelease(_idxPath);
    SafeRelease(_cellContentView);
    SafeRelease(_lineImg);
    SafeRelease(_picImg);
    SafeRelease(_profitImg);
    SafeRelease(_scrollView);
    SafeRelease(_buttonsView);
    SafeRelease(_panGesture);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(NSInteger)type inTableView:(UITableView *)tableView{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.type = type;
        self.tableView=tableView;
        
        self.scrollView=[[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.contentSize=CGSizeMake(self.bounds.size.width+180, self.bounds.size.height);
        self.scrollView.showsHorizontalScrollIndicator=NO;
        self.scrollView.showsVerticalScrollIndicator=NO;
        self.scrollView.delegate=self;
        self.scrollView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.scrollView];
        
        self.buttonsView=[[UIView alloc]initWithFrame:CGRectZero];
        [self.scrollView addSubview:self.buttonsView];
        
        self.hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.hotBtn.backgroundColor = COLOR(81, 81, 81, 81);
        [self.hotBtn addTarget:self action:@selector(hotBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:self.hotBtn];
        
        self.saleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.saleBtn.backgroundColor = COLOR(81, 81, 81, 81);
        [self.saleBtn addTarget:self action:@selector(saleBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:self.saleBtn];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.backgroundColor = COLOR(81, 81, 81, 81);
        [self.deleteBtn addTarget:self action:@selector(deleteBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn setImage:[Utility getImgWithImageName:@"delete_bt@2x"] forState:UIControlStateNormal];
        [self.buttonsView addSubview:self.deleteBtn];
        
        self.cellContentView = [[UIView alloc]initWithFrame:CGRectZero];
        self.cellContentView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.cellContentView];
        
        UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapGesture:)];
        [self.cellContentView addGestureRecognizer:tapGesture];
        
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
        
        self.profitImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.profitImg.image = [Utility getImgWithImageName:@"profit_list_flag@2x"];
        self.profitImg.hidden = YES;
        
        [self.cellContentView addSubview:self.profitImg];
        [self.cellContentView addSubview:self.picImg];
        [self.cellContentView addSubview:self.proCode];
        [self.cellContentView addSubview:self.proPrice];
        [self.cellContentView addSubview:self.proSale];
        [self.cellContentView addSubview:self.proStock];
        [self.cellContentView addSubview:self.saleImg];
        [self.contentView addSubview:self.lineImg];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUnenableScroll:) name:TableViewCellNotificationUnenableScroll object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEnableScroll:) name:TableViewCellNotificationEnableScroll object:nil];
    }
    return self;
}

#pragma mark - 
#pragma mark - action

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

#pragma mark - 
#pragma mark - getter/setter

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
    
    self.profitImg.hidden = YES;
    if (productModel.profitStatus==1) {
        self.profitImg.hidden = NO;
    }
    
    [self.picImg sd_setImageWithURL:[NSURL URLWithString:productModel.picHeader] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    
    [self.hotBtn setImage:[Utility getImgWithImageName:productModel.isHot?@"hot_bt@2x":@"hot_s_bt@2x"] forState:UIControlStateNormal];
    [self.saleBtn setImage:[Utility getImgWithImageName:productModel.isDisplay?@"hide_bt@2x":@"hide_s_bt@2x"] forState:UIControlStateNormal];
}

-(void)setIdxPath:(NSIndexPath *)idxPath {
    _idxPath = idxPath;
}

-(void)setState:(TableViewCellState)state{
    _state=state;
    
    if (state==CellStateExpanded) {
        _editingCell=self;
        [self.scrollView setContentOffset:CGPointMake(180, 0.0f) animated:YES];
        self.tableView.scrollEnabled=NO;
        self.tableView.allowsSelection=NO;
        ///通知所有的cell停止滚动(除自己这个)
        [[NSNotificationCenter defaultCenter] postNotificationName:TableViewCellNotificationUnenableScroll object:nil];
        ///往tableView上添加一个手势处理,使得在tableView上的拖动也只是影响当前这个cell的scrollView
        if (!_panGesture){
            _panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPanGesture:)];
            [self.tableView addGestureRecognizer:_panGesture];
        }
    }else if(state==CellStateUnexpanded) {
        ///停止tableView的手势
        if (_panGesture){
            [self.tableView removeGestureRecognizer:_panGesture];
            _panGesture=nil;
        }
        
        ///为了不让快速按下时鼓动状态固定在一半，一开始就先停止触摸
        self.tableView.userInteractionEnabled=NO;
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.tableView.userInteractionEnabled=YES;
        });
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        ///tableView可以滚动了
        _editingCell=nil;
        self.tableView.scrollEnabled=YES;
        self.tableView.allowsSelection=YES;
        ///通知所有的cell可以滚动
        [[NSNotificationCenter defaultCenter] postNotificationName:TableViewCellNotificationEnableScroll object:nil];
    }
}

#pragma mark - 
#pragma mark - UI

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
    
    self.scrollView.frame = (CGRect){0,0,self.width,self.height};
    self.scrollView.contentSize=CGSizeMake(self.width+180, self.height);
    
    self.cellContentView.frame = (CGRect){0,0,self.width,self.height};
    
    self.saleImg.frame = (CGRect){0,0,3,self.height};
    
    self.picImg.frame = (CGRect){self.saleImg.right+10,5,60,60};
    
    [self.proCode sizeToFit];
    [self.proPrice sizeToFit];
    
    self.proCode.frame = (CGRect){self.picImg.right+10,(self.height-self.proCode.height-self.proPrice.height-5)/2,self.proCode.width,self.proCode.height};
    self.proPrice.frame = (CGRect){self.picImg.right+10,self.proCode.bottom+5,self.proPrice.width,self.proPrice.height};
    
    self.profitImg.frame = (CGRect){self.proPrice.right+5,self.proPrice.top+(self.proPrice.height-10)/2 ,10,10};
    
    
    [self.proStock sizeToFit];
    self.proStock.frame = (CGRect){self.width-self.proStock.width-10,(self.height-self.proStock.height)/2,self.proStock.width,self.proStock.height};
    
    ///库存标题的宽度
    NSDictionary *fontDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGRect rect = [SetTitle(@"stock") boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:fontDic context:nil];
    
    [self.proSale sizeToFit];
    self.proSale.frame = (CGRect){(self.width-10-rect.size.width)-40-self.proSale.width,(self.height-self.proSale.height)/2,self.proSale.width,self.proSale.height};
    
    self.lineImg.frame = (CGRect){self.picImg.left,self.height-0.5,self.width-self.picImg.left,1};
    
    self.buttonsView.frame = (CGRect){self.width-180,0,180,self.height};
    self.hotBtn.frame = (CGRect){0,0,60,self.height};
    self.saleBtn.frame = (CGRect){self.hotBtn.right,0,60,self.height};
    self.deleteBtn.frame = (CGRect){self.saleBtn.right,0,60,self.height};
}

#pragma mark -
#pragma mark - 手势

- (void)onPanGesture:(UIPanGestureRecognizer *)recognizer {
    if (!_editingCell)
        return;
    if (recognizer.state==UIGestureRecognizerStateChanged){
        CGFloat translate_x=[recognizer translationInView:_editingCell.tableView].x;
        CGFloat offset_x=self.buttonsView.frame.size.width;
        CGFloat move_offset_x=offset_x-translate_x;
        [_editingCell.scrollView setContentOffset:CGPointMake(move_offset_x, 0)];
    }
    else if (recognizer.state==UIGestureRecognizerStateEnded||
             recognizer.state==UIGestureRecognizerStateCancelled ||
             recognizer.state==UIGestureRecognizerStateFailed){
        _editingCell.state=CellStateUnexpanded;
    }
}

-(void)onTapGesture:(UITapGestureRecognizer*)recognizer{
    if (_editingCell){
        _editingCell.state=CellStateUnexpanded;
    }else{
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:self];
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:cellIndexPath];
        }
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.buttonsView.transform=CGAffineTransformMakeTranslation(scrollView.contentOffset.x, 0.0f);
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.tableView.scrollEnabled=NO;
    self.tableView.allowsSelection=NO;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.tableView.allowsSelection=YES;
    self.tableView.scrollEnabled=YES;
    if (scrollView.contentOffset.x>=(self.buttonsView.frame.size.width/2)){
        self.state=CellStateExpanded;
    }else{
        self.state=CellStateUnexpanded;
    }
}
#pragma mark -
#pragma mark - 通知

///内部通知所有的cell可以滚动scrollView了
-(void)notificationEnableScroll:(NSNotification*)notification{
    self.scrollView.scrollEnabled=YES;
}
///内部通知所有的cell不可以滚动scrollView(除当前编辑的这个外)
-(void)notificationUnenableScroll:(NSNotification*)notification{
    if (_editingCell!=self) {
        self.scrollView.scrollEnabled=NO;
    }
}
@end
