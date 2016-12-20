//
//  DiscountVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/11/8.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "DiscountVC.h"
#import "RETableViewManager.h"

@interface DiscountVC ()

@property (nonatomic, weak) IBOutlet UITableView *table;
@property (strong, nonatomic) RETableViewManager *manager;

@property (strong, nonatomic) RETextItem *zhekou_Item;

@property (strong, nonatomic) RETextItem *jiage_Item;
@end

@implementation DiscountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.table];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection section];
    [_manager addSection:section];
    
    QWeakSelf(self);
    self.zhekou_Item = [RETextItem itemWithTitle:SetTitle(@"order_zhekou") value:self.discountType==0?[NSString stringWithFormat:@"%.2f",self.discount]:@"0" placeholder:@"0"];
    self.zhekou_Item.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            
            weakself.discountType = 0;
            weakself.discount = [item.value floatValue];
            
            [weakself.jiage_Item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }else {
            item.textFieldColor = kDeleteColor;
        }
    };
    self.zhekou_Item.validators = @[@"presence", @"number"];
    self.zhekou_Item.alignment = NSTextAlignmentRight;
    self.zhekou_Item.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.zhekou_Item];
    
    
    self.jiage_Item = [RETextItem itemWithTitle:SetTitle(@"order_jine") value:self.discountType==1?[NSString stringWithFormat:@"%.2f",self.discount]:@"0" placeholder:@"0"];
    self.jiage_Item.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            
            weakself.discountType = 1;
            weakself.discount = [item.value floatValue];
            
            [weakself.zhekou_Item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }else {
            item.textFieldColor = kDeleteColor;
        }
    };
    self.jiage_Item.validators = @[@"presence", @"number"];
    self.jiage_Item.alignment = NSTextAlignmentRight;
    self.jiage_Item.keyboardType = UIKeyboardTypeNumberPad;
    [section addItem:self.jiage_Item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"product_disount") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    [Utility setExtraCellLineHidden:self.table];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.view endEditing:YES];
    
    //判断数据
    NSArray *managerErrors = self.manager.errors;
    if (managerErrors.count > 0) {
        NSMutableArray *errors = [NSMutableArray array];
        for (NSError *error in managerErrors) {
            [errors addObject:error.localizedDescription];
        }
        NSString *errorString = [errors componentsJoinedByString:@"\n"];
        
        __weak __typeof(self)weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"edit_discount_error") message:errorString preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel") action:^(UIAlertAction *action) {
            if (weakSelf.completedBlock) {
                weakSelf.completedBlock (weakSelf.discountType,weakSelf.discount);
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        if (self.completedBlock) {
            self.completedBlock (self.discountType,self.discount);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
