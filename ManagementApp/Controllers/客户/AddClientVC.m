//
//  AddClientVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "AddClientVC.h"

#import "RETableViewManager.h"
#import "ClientTypeVC.h"
#import "BlockAlertView.h"

@interface AddClientVC ()<RETableViewManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;

@property (nonatomic, assign) CGFloat keyboardHeight;

///根据clientModel判断是新建还是修改
@property (nonatomic, assign) BOOL isNew;

@property (nonatomic, assign) BOOL isValidation;
@end

@implementation AddClientVC

-(void)dealloc {
    SafeRelease(_tableView);
    SafeRelease(_manager);
}

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.clientModel) {
        self.isNew = NO;
    }else {
        self.isNew = YES;
        self.clientModel = [[ClientModel alloc]init];
        self.clientModel.clientLevel = 0;
        self.clientModel.clientType = 0;
        self.clientModel.isPrivate = NO;
        self.clientModel.isCommand = NO;
        self.clientModel.isShowPrice = YES;
        self.clientModel.isShowStock = YES;
    }
    
    [self setNavBarView];
    
    [self setTableViewUI];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (!self.view.window){
        SafeRelease(_tableView);
        SafeRelease(_manager);
        self.view=nil;
    }
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:self.isNew?SetTitle(@"detail"):self.clientModel.clientName image:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    
    if (self.isNew) {
        self.navBarView.rightEnable = NO;
    }
    
    [self.view addSubview:self.navBarView];
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStyleGrouped];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    _manager.delegate = self;
    // Add a section
    RETableViewSection *section1 = [RETableViewSection section];
    [_manager addSection:section1];
    
    __weak __typeof(self)weakSelf = self;
    
    NSMutableArray *collapsedItems = [NSMutableArray array];
    NSMutableArray *expandedItems = [NSMutableArray array];
    
    //类型
    RERadioItem *typeItem = [RERadioItem itemWithTitle:SetTitle(@"type") value:self.clientModel.clientType==0?SetTitle(@"customer"):SetTitle(@"supplier") selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        NSArray *options = @[SetTitle(@"customer"),SetTitle(@"supplier")];
        
        ClientTypeVC *typeVC = [[ClientTypeVC alloc]initWithNibName:nil bundle:nil item:item options:options multipleChoice:NO completionHandler:^(RETableViewItem *selectedItem){
            [weakSelf.navigationController popViewControllerAnimated:YES];
            DLog(@"selectedItem = %@",selectedItem.title);
            
            if ([selectedItem.title isEqualToString:SetTitle(@"customer")]) {
                weakSelf.clientModel.clientType=0;
                
                [section1 replaceItemsWithItemsFromArray:expandedItems];
                [section1 reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
            }else {
                weakSelf.clientModel.clientType=1;
                
                [section1 replaceItemsWithItemsFromArray:collapsedItems];
                [section1 reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
            }
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }];
        typeVC.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:typeVC animated:YES];
        SafeRelease(typeVC);
    }];
    [expandedItems addObject:typeItem];
    [collapsedItems addObject:typeItem];
    
    //等级
    RELevelItem *levelItem = [RELevelItem itemWithTitle:SetTitle(@"level") index:self.clientModel.clientLevel];
    levelItem.selectionStyle = UITableViewCellSelectionStyleNone;
    levelItem.onChange = ^(RELevelItem *item){
        weakSelf.clientModel.clientLevel = item.currentIndex;
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
    };
    [expandedItems addObject:levelItem];
    
    //显示价格
    REBoolItem *displayItem = [REBoolItem itemWithTitle:SetTitle(@"price_display") value:self.clientModel.isShowPrice switchValueChangeHandler:^(REBoolItem *item) {
        weakSelf.clientModel.isShowPrice = item.value;
    }];
    [expandedItems addObject:displayItem];
    
    //显示库存
    REBoolItem *stockItem = [REBoolItem itemWithTitle:SetTitle(@"stock_display") value:self.clientModel.isShowStock switchValueChangeHandler:^(REBoolItem *item) {
        weakSelf.clientModel.isShowStock = item.value;
    }];
    [expandedItems addObject:stockItem];
    
    if (self.clientModel.clientType==0) {//顾客
        [section1 replaceItemsWithItemsFromArray:expandedItems];
        [section1 reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
    }else {//供货商
        [section1 replaceItemsWithItemsFromArray:collapsedItems];
        [section1 reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Add a section
    RETableViewSection *section2 = [RETableViewSection section];
    [_manager addSection:section2];
    
    //名字
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"name") value:self.clientModel.clientName?self.clientModel.clientName:@"" placeholder:[NSString stringWithFormat:@"%@ %@",SetTitle(@"name"),SetTitle(@"product_required")]];
    nameItem.onChange = ^(RETextItem *item){
        [weakSelf checkData];
        weakSelf.clientModel.clientName = item.value;
    };
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.validators = @[@"presence"];
    [section2 addItem:nameItem];
    
    //电话
    RETextItem *phoneItem = [RETextItem itemWithTitle:SetTitle(@"phone") value:self.clientModel.clientPhone?self.clientModel.clientPhone:@"" placeholder:[NSString stringWithFormat:@"%@ %@",SetTitle(@"phone"),SetTitle(@"product_required")]];
    phoneItem.onChange = ^(RETextItem *item){
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            [weakSelf checkData];
            weakSelf.clientModel.clientPhone = item.value;
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    phoneItem.keyboardType = UIKeyboardTypeNumberPad;
    phoneItem.alignment = NSTextAlignmentRight;
    phoneItem.validators = @[@"presence"];
    [section2 addItem:phoneItem];
    
    //邮箱
    RETextItem *emailItem = [RETextItem itemWithTitle:SetTitle(@"email") value:self.clientModel.clientEmail?self.clientModel.clientEmail:@"" placeholder:SetTitle(@"product_set")];
    emailItem.onChange = ^(RETextItem *item){
        weakSelf.clientModel.clientEmail = item.value;
    };
    emailItem.keyboardType = UIKeyboardTypeEmailAddress;
    emailItem.alignment = NSTextAlignmentRight;
    emailItem.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [section2 addItem:emailItem];
    
    
    // Add a section
    RETableViewSection *section3 = [RETableViewSection section];
    [_manager addSection:section3];
    
    //备注
    RETextItem *markItem = [RETextItem itemWithTitle:SetTitle(@"product_mark") value:self.clientModel.clientRemark?self.clientModel.clientRemark:@"" placeholder:SetTitle(@"product_set")];
    markItem.onChange = ^(RETextItem *item){
        weakSelf.clientModel.clientRemark = item.value;
    };
    markItem.alignment = NSTextAlignmentRight;
    [section3 addItem:markItem];
    
    
    for (int i=0; i<10; i++) {
        RETableViewSection *section21 = [RETableViewSection section];
        [_manager addSection:section21];
        //名字
        RETextItem *nameItem1 = [RETextItem itemWithTitle:SetTitle(@"name") value:self.clientModel.clientName?self.clientModel.clientName:@"" placeholder:[NSString stringWithFormat:@"%@ %@",SetTitle(@"name"),SetTitle(@"product_required")]];
        nameItem1.alignment = NSTextAlignmentRight;
        nameItem1.validators = @[@"presence"];
        [section21 addItem:nameItem1];
    }
    
}

-(void)checkData {
    NSArray *managerErrors = self.manager.errors;
    if (managerErrors.count > 0) {
        self.navBarView.rightEnable = NO;
    }else {
        self.navBarView.rightEnable = YES;
    }
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    [self.view endEditing:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    if ([Utility checkString:self.clientModel.clientId] && self.isEditing){//编辑客户
        BlockAlertView *alert = [BlockAlertView alertWithTitle:SetTitle(@"client_editing") message:nil];
        [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
            
        }];
        [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.clientModel.clientId];
                post[@"clientType"] = @(weakSelf.clientModel.clientType);
                if (weakSelf.clientModel.clientType==0) {
                    post[@"clientLevel"] = @(weakSelf.clientModel.clientLevel);
                    post[@"isShowPrice"] = @(weakSelf.clientModel.isShowPrice);
                    post[@"isShowStock"] = @(weakSelf.clientModel.isShowStock);
                }
                post[@"clientName"] = weakSelf.clientModel.clientName;
                post[@"clientPhone"] = weakSelf.clientModel.clientPhone;
                post[@"clientEmail"] = weakSelf.clientModel.clientEmail;
                post[@"clientRemark"] = weakSelf.clientModel.clientRemark;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AVObject saveAllInBackground:@[post] block:^(BOOL succeeded, NSError *error){
                        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        if (!error) {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                });
            });
        }];
        [alert show];
    }else {//创建客户
        BlockAlertView *alert = [BlockAlertView alertWithTitle:SetTitle(@"client_creat") message:nil];
        [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
            
        }];
        [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                AVObject *post = [AVObject objectWithClassName:@"Client"];

                post[@"clientType"] = @(weakSelf.clientModel.clientType);
                if (weakSelf.clientModel.clientType==0) {
                    post[@"clientLevel"] = @(weakSelf.clientModel.clientLevel);
                    post[@"isShowPrice"] = @(weakSelf.clientModel.isShowPrice);
                    post[@"isShowStock"] = @(weakSelf.clientModel.isShowStock);
                }
                post[@"clientName"] = weakSelf.clientModel.clientName;
                post[@"clientPhone"] = weakSelf.clientModel.clientPhone;
                post[@"clientEmail"] = weakSelf.clientModel.clientEmail;
                post[@"clientRemark"] = weakSelf.clientModel.clientRemark;
                
                NSString *code = [Utility getPlateForm];
                post[@"command"] = code;
                
                [post setObject:[AVUser currentUser] forKey:@"user"];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [AVObject saveAllInBackground:@[post] block:^(BOOL succeeded, NSError *error){
                        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        if (!error) {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                });
            });
        }];
        [alert show];
    }
        
    //保存
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         self.tableView.frame = frame;
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
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         self.tableView.frame = frame;
                         self.keyboardHeight = 0;
                     }];
}



@end
