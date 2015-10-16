//
//  ProductVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductVC.h"

#import "RFSegmentView.h"
#import "RETableViewManager.h"

#import "ProductPriceVC.h"
#import "MaterialVC.h"
#import "ClassifyVC.h"
#import "StockWarningVC.h"

@interface ProductVC ()<RFSegmentViewDelegate>

@property (nonatomic, strong) RFSegmentView* segmentView;

@property (nonatomic, strong) UITableView *descriptionTable;
@property (nonatomic, strong) RETableViewManager *descriptionManager;

@property (nonatomic, strong) UITableView *stockTable;
@property (nonatomic, strong) RETableViewManager *stockManager;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation ProductVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    self.isNewProduct = YES;
    
    self.currentPage = 0;
    
    [self setNavBarView];
    [self setSegmentControl];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:self.isNewProduct?@"cancel_bt":@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"]];
    [self.navBarView setTitle:self.isNewProduct?SetTitle(@"product"):@"dd" image:nil];
    [self.view addSubview:self.navBarView];
}

-(void)setSegmentControl {
    self.segmentView = [[RFSegmentView alloc] initWithFrame:(CGRect){(self.view.width-300)/2,self.navBarView.bottom+10,300,40} items:@[SetTitle(@"Description"),SetTitle(@"stock")]];
    self.segmentView.tintColor       = COLOR(80, 80, 80, 1);
    self.segmentView.delegate        = self;
    self.segmentView.selectedIndex   = 0;
    [self.view addSubview:self.segmentView];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:(CGRect){0,self.segmentView.bottom+10,self.view.width,0.5}];
    img.backgroundColor = COLOR(80, 80, 80, 1);
    [self.view addSubview:img];
    
    [self setDescriptionTableView];
    [self setStockTableView];
    
    [self.view bringSubviewToFront:img];
    img = nil;
}

-(void)setDescriptionTableView {
    self.descriptionTable = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60} style:UITableViewStylePlain];
    [Utility setExtraCellLineHidden:self.descriptionTable];
    [self.view addSubview:self.descriptionTable];
    
    // Create manager
    _descriptionManager = [[RETableViewManager alloc] initWithTableView:self.descriptionTable];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@""];
    [_descriptionManager addSection:section];
    
    // Add items
    
    //货号必填
    RETextItem *codeItem = [RETextItem itemWithTitle:SetTitle(@"product_code") value:@"" placeholder:SetTitle(@"product_required")];
    codeItem.onChange = ^(RETextItem *item){
        
    };
    codeItem.alignment = NSTextAlignmentRight;
    [section addItem:codeItem];
    
    //价格选择
    __weak __typeof(self)weakSelf = self;
    RERadioItem *radioItem = [RERadioItem itemWithTitle:SetTitle(@"sale_price") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        item.value = @"dd";
        item.infoImg = [UIImage imageNamed:@"charc_1_28"];
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        ProductPriceVC *priceVC = LOADVC(@"ProductPriceVC");
        priceVC.completedBlock = ^(BOOL success){
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:priceVC animated:YES];
        
    }];
    [section addItem:radioItem];
    
    //进货价
    RETextItem *purchaseItem = [RETextItem itemWithTitle:SetTitle(@"purchase_price") value:@"" placeholder:SetTitle(@"product_set")];
    purchaseItem.onChange = ^(RETextItem *item){
        
    };
    purchaseItem.keyboardType = UIKeyboardTypeNumberPad;
    purchaseItem.alignment = NSTextAlignmentRight;
    [section addItem:purchaseItem];
    
    //包装数
    REPickerItem *pickerItem = [REPickerItem itemWithTitle:SetTitle(@"product_package") value:@[@"1"] placeholder:nil options:@[@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30"]]];
    pickerItem.onChange = ^(REPickerItem *item){
//        NSLog(@"Value: %@", item.value);
    };
    pickerItem.inlinePicker = YES;
    [section addItem:pickerItem];
    
    //名称
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"product_name") value:@"" placeholder:SetTitle(@"product_set")];
    nameItem.onChange = ^(RETextItem *item){
        
    };
    nameItem.alignment = NSTextAlignmentRight;
    [section addItem:nameItem];
    
    //材质
    RERadioItem *materialItem = [RERadioItem itemWithTitle:SetTitle(@"material") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        item.value = @"dd";
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        MaterialVC *materialVC = [[MaterialVC alloc]init];
        materialVC.completedBlock = ^(MaterialModel *materialModel){
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:materialVC animated:YES];
        
    }];
    [section addItem:materialItem];
    
    //分类
    RERadioItem *classifyItem = [RERadioItem itemWithTitle:SetTitle(@"classify") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        item.value = @"dd";
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        ClassifyVC *classifyVC = [[ClassifyVC alloc]init];
        classifyVC.completedBlock = ^(SortModel *sortModel){
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:classifyVC animated:YES];
        
    }];
    [section addItem:classifyItem];
    
    //备注
    RETextItem *markItem = [RETextItem itemWithTitle:SetTitle(@"product_mark") value:@"" placeholder:SetTitle(@"product_set")];
    markItem.onChange = ^(RETextItem *item){
        
    };
    markItem.alignment = NSTextAlignmentRight;
    [section addItem:markItem];
    
    //上架
    REBoolItem *displayItem = [REBoolItem itemWithTitle:SetTitle(@"product_display") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        NSLog(@"Value: %@", item.value ? @"YES" : @"NO");
    }];
    [section addItem:displayItem];
    
    //热卖
    REBoolItem *promotionlItem = [REBoolItem itemWithTitle:SetTitle(@"product_promotion") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        NSLog(@"Value: %@", item.value ? @"YES" : @"NO");
    }];
    [section addItem:promotionlItem];
    
    //库存警告
    RERadioItem *stockItem = [RERadioItem itemWithTitle:SetTitle(@"stock_waring") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];

        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        StockWarningVC *stockVC = [[StockWarningVC alloc]init];
        stockVC.completedBlock = ^(BOOL success){
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:stockVC animated:YES];
        
    }];
    [section addItem:stockItem];
}

-(void)setStockTableView {
    self.stockTable = [[UITableView alloc]initWithFrame:(CGRect){self.view.width,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60} style:UITableViewStylePlain];
//    [Utility setExtraCellLineHidden:self.stockTable];
    [self.view addSubview:self.stockTable];
    
    // Create manager
    _stockManager = [[RETableViewManager alloc] initWithTableView:self.stockTable];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@""];
    [_stockManager addSection:section];
    
    // Add items
}
#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {

}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    
}

#pragma mark - segmentView代理

- (void)segmentViewDidSelected:(NSUInteger)index {
    if (index==self.currentPage) {
        //do nothing
    }else {
        self.currentPage = index;
        __weak __typeof(self)weakSelf = self;
        if (index==0) {
            [UIView animateWithDuration:0.25f animations:^{
                weakSelf.descriptionTable.frame = (CGRect){0,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
                weakSelf.stockTable.frame = (CGRect){self.view.width,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
            }];
        }else {
            [UIView animateWithDuration:0.25f animations:^{
                weakSelf.descriptionTable.frame = (CGRect){0-self.view.width,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
                weakSelf.stockTable.frame = (CGRect){0,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
            }];
        }
    }
}

#pragma mark - keyboard

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.descriptionTable.frame;
                         frame.size.height += self.keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         self.descriptionTable.frame = frame;
                         self.keyboardHeight = keyboardRect.size.height;
                     }];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.descriptionTable.frame;
                         frame.size.height += self.keyboardHeight;
                         self.descriptionTable.frame = frame;
                         self.keyboardHeight = 0;
                     }];
}

@end
