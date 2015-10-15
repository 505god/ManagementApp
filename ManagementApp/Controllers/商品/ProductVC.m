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

@interface ProductVC ()<RFSegmentViewDelegate>

@property (nonatomic, strong) RFSegmentView* segmentView;

@property (nonatomic, strong) UITableView *descriptionTable;
@property (nonatomic, strong) RETableViewManager *descriptionManager;

@property (nonatomic, strong) UITableView *stockTable;
@property (nonatomic, strong) RETableViewManager *stockManager;

@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation ProductVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNewProduct = YES;
    
    self.currentPage = 0;
    
    [self setNavBarView];
    [self setSegmentControl];
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
//    RERadioItem *radioItem = [RERadioItem itemWithTitle:<#(NSString *)#> value:<#(NSString *)#> selectionHandler:<#^(RERadioItem *item)selectionHandler#>]
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

@end
