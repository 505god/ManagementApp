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
    //－－－－－－－－－－－－－－－－－A
    self.aItem = [RETextItem itemWithTitle:@"      " value:@"" placeholder:[NSString stringWithFormat:@"%@  %@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.aItem.onChange = ^(RETextItem *item){
        
    };
    
    __weak __typeof(self)weakSelf = self;
    self.aItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        
        if (item.isHighlighted) {
            //do nothing
        }else {
            
        }
        item.isHighlighted = YES;
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.bItem.isHighlighted = NO;
        [weakSelf.bItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.cItem.isHighlighted = NO;
        [weakSelf.cItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.dItem.isHighlighted = NO;
        [weakSelf.dItem reloadRowWithAnimation:UITableViewRowAnimationNone];
    };
    
    self.aItem.image = [UIImage imageNamed:@"charc_1_28"];
    self.aItem.highlightedImage = [UIImage imageNamed:@"charc_1_28_sele"];
    self.aItem.alignment = NSTextAlignmentRight;
    self.aItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.aItem];
    
    //－－－－－－－－－－－－－－－－－B
    self.bItem = [RETextItem itemWithTitle:@"      " value:@"" placeholder:[NSString stringWithFormat:@"%@  %@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.bItem.onChange = ^(RETextItem *item){
        
    };
    self.bItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        item.isHighlighted = YES;
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.aItem.isHighlighted = NO;
        [weakSelf.aItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.cItem.isHighlighted = NO;
        [weakSelf.cItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.dItem.isHighlighted = NO;
        [weakSelf.dItem reloadRowWithAnimation:UITableViewRowAnimationNone];
    };
    self.bItem.image = [UIImage imageNamed:@"charc_2_28"];
    self.bItem.highlightedImage = [UIImage imageNamed:@"charc_2_28_sele"];
    self.bItem.alignment = NSTextAlignmentRight;
    self.bItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.bItem];
    
    //－－－－－－－－－－－－－－－－－C
    self.cItem = [RETextItem itemWithTitle:@"      " value:@"" placeholder:[NSString stringWithFormat:@"%@  %@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.cItem.onChange = ^(RETextItem *item){
        
    };
    self.cItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        item.isHighlighted = YES;
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.aItem.isHighlighted = NO;
        [weakSelf.aItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.bItem.isHighlighted = NO;
        [weakSelf.bItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.dItem.isHighlighted = NO;
        [weakSelf.dItem reloadRowWithAnimation:UITableViewRowAnimationNone];
    };
    self.cItem.image = [UIImage imageNamed:@"charc_3_28"];
    self.cItem.highlightedImage = [UIImage imageNamed:@"charc_3_28_sele"];
    self.cItem.alignment = NSTextAlignmentRight;
    self.cItem.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.cItem];
    
    //－－－－－－－－－－－－－－－－－D
    self.dItem = [RETextItem itemWithTitle:@"      " value:@"" placeholder:[NSString stringWithFormat:@"%@  %@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.dItem.onChange = ^(RETextItem *item){
        
    };
    self.dItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        item.isHighlighted = YES;
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.aItem.isHighlighted = NO;
        [weakSelf.aItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.bItem.isHighlighted = NO;
        [weakSelf.bItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        
        weakSelf.cItem.isHighlighted = NO;
        [weakSelf.cItem reloadRowWithAnimation:UITableViewRowAnimationNone];
    };
    self.dItem.image = [UIImage imageNamed:@"charc_4_28"];
    self.dItem.highlightedImage = [UIImage imageNamed:@"charc_4_28_sele"];
    self.dItem.alignment = NSTextAlignmentRight;
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

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {

    if (self.completedBlock) {
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {

}



@end
