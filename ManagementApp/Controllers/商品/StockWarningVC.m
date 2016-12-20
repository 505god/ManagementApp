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
-(void)dealloc {
    SafeRelease(_table);
    SafeRelease(_manager);
    SafeRelease(_stockWarningModel);
    SafeRelease(_completedBlock);
}
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
    
    
   __weak __typeof(self)weakSelf = self;
    REBoolItem *promotionlItem = [REBoolItem itemWithTitle:SetTitle(@"stock_warning") value:self.stockWarningModel.isSetting switchValueChangeHandler:^(REBoolItem *item) {
        
        weakSelf.stockWarningModel.isSetting = item.value;
        if (item.value) {
            for (id obj in expandedItems) {
                if ([obj isKindOfClass:[RETextItem class]]) {
                    RETextItem *ii = (RETextItem *)obj;
                    
                    ii.value = @"";
                }
            }
            
            [section replaceItemsWithItemsFromArray:expandedItems];
            [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
        }else {
            weakSelf.stockWarningModel.totalNum = 0;
            weakSelf.stockWarningModel.singleNum = 0;
            
            [section replaceItemsWithItemsFromArray:collapsedItems];
            [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    [section addItem:promotionlItem];
    
    
    [collapsedItems addObject:promotionlItem];
    [expandedItems addObject:promotionlItem];
    
    RETextItem *aItem = [RETextItem itemWithTitle:SetTitle(@"stock_all") value:self.stockWarningModel.totalNum==0?@"":[NSString stringWithFormat:@"%d",(int)self.stockWarningModel.totalNum] placeholder:@"0"];
    aItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.stockWarningModel.totalNum = [item.value integerValue];
        }else {
            item.textFieldColor = kDeleteColor;
        }
    };
    aItem.validators = @[@"presence", @"number"];
    aItem.alignment = NSTextAlignmentRight;
    aItem.keyboardType = UIKeyboardTypeNumberPad;
    [expandedItems addObject:aItem];
    
    RETextItem *bItem = [RETextItem itemWithTitle:SetTitle(@"stock_one") value:self.stockWarningModel.singleNum==0?@"":[NSString stringWithFormat:@"%d",(int)self.stockWarningModel.singleNum] placeholder:@"0"];
    bItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.stockWarningModel.singleNum = [item.value integerValue];
        }else {
            item.textFieldColor = kDeleteColor;
        }
    };
    bItem.validators = @[@"presence", @"number"];
    bItem.alignment = NSTextAlignmentRight;
    bItem.keyboardType = UIKeyboardTypeNumberPad;
    [expandedItems addObject:bItem];
    
    if (self.stockWarningModel.isSetting) {
        [section addItem:aItem];
        [section addItem:bItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (!self.view.window){
        SafeRelease(_table);
        SafeRelease(_manager);
        SafeRelease(_stockWarningModel);
        SafeRelease(_completedBlock);
        self.view=nil;
    }
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"stock_warning") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    [Utility setExtraCellLineHidden:self.table];
}

#pragma mark - 导航栏代理

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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"edit_stock_error") message:errorString preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel") action:^(UIAlertAction *action) {
            if (weakSelf.completedBlock) {
                weakSelf.completedBlock (weakSelf.stockWarningModel,NO);
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        if (self.completedBlock) {
            self.completedBlock (self.stockWarningModel,YES);
        }
    
    [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
