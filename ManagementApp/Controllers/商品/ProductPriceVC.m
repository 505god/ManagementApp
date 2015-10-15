//
//  ProductPriceVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductPriceVC.h"

@interface ProductPriceVC ()

@property (strong, readwrite, nonatomic) RETextItem *aItem;
@property (strong, readwrite, nonatomic) RETextItem *bItem;
@property (strong, readwrite, nonatomic) RETextItem *cItem;
@property (strong, readwrite, nonatomic) RETextItem *dItem;

@end

@implementation ProductPriceVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.table];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@""];
    [_manager addSection:section];
    
    // Add items
    
    self.aItem = [RETextItem itemWithTitle:@"   " value:@"" placeholder:SetTitle(@"price")];
    self.aItem.onChange = ^(RETextItem *item){
        
    };

    self.aItem.image = [UIImage imageNamed:@"charc_1_15"];
    self.aItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.aItem];
    
    self.bItem = [RETextItem itemWithTitle:@"   " value:@"" placeholder:SetTitle(@"price")];
    self.bItem.onChange = ^(RETextItem *item){
        
    };
    self.bItem.image = [UIImage imageNamed:@"charc_2_15"];
    self.bItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.bItem];
    
    self.cItem = [RETextItem itemWithTitle:@"   " value:@"" placeholder:SetTitle(@"price")];
    self.cItem.onChange = ^(RETextItem *item){
        
    };
    self.cItem.image = [UIImage imageNamed:@"charc_3_15"];
    self.cItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.cItem];
    
    self.dItem = [RETextItem itemWithTitle:@"   " value:@"" placeholder:SetTitle(@"price")];
    self.dItem.onChange = ^(RETextItem *item){
        
    };
    self.dItem.image = [UIImage imageNamed:@"charc_4_15"];
    self.dItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.dItem];
    
    [Utility setExtraCellLineHidden:self.table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"price") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
}


@end
