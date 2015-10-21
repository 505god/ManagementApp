//
//  ProductPriceVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductPriceVC.h"
#import "BlockAlertView.h"

@interface ProductPriceVC ()

@property (strong, readwrite, nonatomic) RETextItem *aItem;
@property (strong, readwrite, nonatomic) RETextItem *bItem;
@property (strong, readwrite, nonatomic) RETextItem *cItem;
@property (strong, readwrite, nonatomic) RETextItem *dItem;

///根据self.productPriceModel判断是新建还是修改
@property (nonatomic, assign) BOOL isNew;

@end

@implementation ProductPriceVC
-(void)dealloc {
    SafeRelease(_aItem);
    SafeRelease(_bItem);
    SafeRelease(_cItem);
    SafeRelease(_dItem);
    SafeRelease(_table);
    SafeRelease(_manager);
    SafeRelease(_productPriceModel);
}
#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    if (self.productPriceModel) {
        self.isNew = NO;
    }else {
        self.isNew = YES;
        self.productPriceModel = [[ProductPriceModel alloc]init];
        self.productPriceModel.selected=-1;
    }
    
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.table];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection section];
    [_manager addSection:section];
    
    // Add items
    //－－－－－－－－－－－－－－－－－A
    __weak __typeof(self)weakSelf = self;
    
    self.aItem = [RETextItem itemWithTitle:[NSString stringWithFormat:@"A %@",SetTitle(@"column")] value:self.isNew?@"":[NSString stringWithFormat:@"%.2f",self.productPriceModel.aPrice] placeholder:[NSString stringWithFormat:@"%@%@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.aItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]+(.[0-9]{1,2})?$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.productPriceModel.aPrice = [item.value floatValue];
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
        
    };
    self.aItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        
        if (item.isHighlighted) {
            weakSelf.productPriceModel.selected = -1;
            item.isHighlighted = NO;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }else {
            weakSelf.productPriceModel.selected = 0;
            item.isHighlighted = YES;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.bItem.isHighlighted = NO;
            [weakSelf.bItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.cItem.isHighlighted = NO;
            [weakSelf.cItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.dItem.isHighlighted = NO;
            [weakSelf.dItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        }
    };
    self.aItem.validators = @[@"presence", @"price"];
    self.aItem.isShowTitle = NO;
    self.aItem.image = [Utility getImgWithImageName:@"charc_1_28@2x"];
    self.aItem.highlightedImage = [Utility getImgWithImageName:@"charc_1_28_sele@2x"];
    self.aItem.alignment = NSTextAlignmentRight;
    self.aItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [section addItem:self.aItem];
    
    //－－－－－－－－－－－－－－－－－B
    self.bItem = [RETextItem itemWithTitle:[NSString stringWithFormat:@"B %@",SetTitle(@"column")] value:self.isNew?@"":[NSString stringWithFormat:@"%.2f",self.productPriceModel.bPrice] placeholder:[NSString stringWithFormat:@"%@%@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.bItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]+(.[0-9]{1,2})?$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.productPriceModel.bPrice = [item.value floatValue];
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    self.bItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        
        if (item.isHighlighted) {
            weakSelf.productPriceModel.selected = -1;
            item.isHighlighted = NO;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }else {
            weakSelf.productPriceModel.selected = 1;
            item.isHighlighted = YES;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.aItem.isHighlighted = NO;
            [weakSelf.aItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.cItem.isHighlighted = NO;
            [weakSelf.cItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.dItem.isHighlighted = NO;
            [weakSelf.dItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        }
    };
    self.bItem.validators = @[@"presence", @"price"];
    self.bItem.isShowTitle = NO;
    self.bItem.image = [Utility getImgWithImageName:@"charc_2_28@2x"];
    self.bItem.highlightedImage = [Utility getImgWithImageName:@"charc_2_28_sele@2x"];
    self.bItem.alignment = NSTextAlignmentRight;
    self.bItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [section addItem:self.bItem];
    
    //－－－－－－－－－－－－－－－－－C
    self.cItem = [RETextItem itemWithTitle:[NSString stringWithFormat:@"C %@",SetTitle(@"column")] value:self.isNew?@"":[NSString stringWithFormat:@"%.2f",self.productPriceModel.cPrice] placeholder:[NSString stringWithFormat:@"%@%@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.cItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]+(.[0-9]{1,2})?$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.productPriceModel.cPrice = [item.value floatValue];
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    self.cItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        if (item.isHighlighted) {
            weakSelf.productPriceModel.selected = -1;
            item.isHighlighted = NO;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }else {
            weakSelf.productPriceModel.selected = 2;
            
            item.isHighlighted = YES;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.aItem.isHighlighted = NO;
            [weakSelf.aItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.bItem.isHighlighted = NO;
            [weakSelf.bItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.dItem.isHighlighted = NO;
            [weakSelf.dItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        }
    };
    self.cItem.validators = @[@"presence", @"price"];
    self.cItem.isShowTitle = NO;
    self.cItem.image = [Utility getImgWithImageName:@"charc_3_28@2x"];
    self.cItem.highlightedImage = [Utility getImgWithImageName:@"charc_3_28_sele@2x"];
    self.cItem.alignment = NSTextAlignmentRight;
    self.cItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [section addItem:self.cItem];
    
    //－－－－－－－－－－－－－－－－－D
    self.dItem = [RETextItem itemWithTitle:[NSString stringWithFormat:@"D %@",SetTitle(@"column")] value:self.isNew?@"":[NSString stringWithFormat:@"%.2f",self.productPriceModel.dPrice] placeholder:[NSString stringWithFormat:@"%@%@",SetTitle(@"price"),SetTitle(@"product_required")]];
    self.dItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]+(.[0-9]{1,2})?$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.productPriceModel.dPrice = [item.value floatValue];
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    self.dItem.selectionHandler = ^(RETableViewItem *item){
        [item deselectRowAnimated:YES];
        
        if (item.isHighlighted) {
            weakSelf.productPriceModel.selected = -1;
            item.isHighlighted = NO;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }else {
            weakSelf.productPriceModel.selected = 3;
            item.isHighlighted = YES;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.aItem.isHighlighted = NO;
            [weakSelf.aItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.bItem.isHighlighted = NO;
            [weakSelf.bItem reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            weakSelf.cItem.isHighlighted = NO;
            [weakSelf.cItem reloadRowWithAnimation:UITableViewRowAnimationNone];
        }
    };
    self.dItem.validators = @[@"presence", @"price"];
    self.dItem.isShowTitle = NO;
    self.dItem.image = [Utility getImgWithImageName:@"charc_4_28@2x"];
    self.dItem.highlightedImage = [Utility getImgWithImageName:@"charc_4_28_sele@2x"];
    self.dItem.alignment = NSTextAlignmentRight;
    self.dItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
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
        BlockAlertView *alert = [BlockAlertView alertWithTitle:SetTitle(@"edit_price_error") message:errorString];
        [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
            if (weakSelf.completedBlock) {
                weakSelf.completedBlock (weakSelf.productPriceModel,NO);
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
            
        }];
        [alert show];
    }else {
        if (self.completedBlock) {
            self.completedBlock (self.productPriceModel,YES);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    
}



@end
