//
//  StockWarningVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "StockWarningVC.h"
#import "RETableViewManager.h"

@interface StockWarningVC ()

@property (nonatomic, weak) IBOutlet UITableView *table;
@property (strong, nonatomic) RETableViewManager *manager;
@end

@implementation StockWarningVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.table];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection section];
    [_manager addSection:section];
    
    // Add items
    
    NSMutableArray *collapsedItems = [NSMutableArray array];
    NSMutableArray *expandedItems = [NSMutableArray array];
    
    REBoolItem *promotionlItem = [REBoolItem itemWithTitle:SetTitle(@"stock_waring") value:NO switchValueChangeHandler:^(REBoolItem *item) {
        if (item.value) {
            [section replaceItemsWithItemsFromArray:expandedItems];
            [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
        }else {
            [section replaceItemsWithItemsFromArray:collapsedItems];
            [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    [section addItem:promotionlItem];
    
    
    [collapsedItems addObject:promotionlItem];
    [expandedItems addObject:promotionlItem];
    
    RETextItem *aItem = [RETextItem itemWithTitle:SetTitle(@"stock_all") value:@"" placeholder:@"0"];
    aItem.onChange = ^(RETextItem *item){
        
    };
    aItem.alignment = NSTextAlignmentRight;
    aItem.keyboardType = UIKeyboardTypeNumberPad;
    [expandedItems addObject:aItem];
    
    RETextItem *bItem = [RETextItem itemWithTitle:SetTitle(@"stock_one") value:@"" placeholder:@"0"];
    bItem.onChange = ^(RETextItem *item){
        
    };
    bItem.alignment = NSTextAlignmentRight;
    bItem.keyboardType = UIKeyboardTypeNumberPad;
    [expandedItems addObject:bItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"stock_waring") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    [Utility setExtraCellLineHidden:self.table];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    
    if (self.completedBlock) {
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
