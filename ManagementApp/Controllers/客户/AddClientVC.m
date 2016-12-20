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
        self.clientModel.isMutable = NO;
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
    [self.navBarView setTitle:self.isNew?SetTitle(@"customer"):self.clientModel.clientName image:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    
    if (self.isNew) {
        self.navBarView.rightEnable = NO;
    }
    
    [self.view addSubview:self.navBarView];
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    _manager.delegate = self;

    __weak __typeof(self)weakSelf = self;
    
    RETableViewSection *section1 = [RETableViewSection section];
    [_manager addSection:section1];
    
    RETableViewSection *section21 = [RETableViewSection section];
    
    //类型
    RERadioItem *typeItem = [RERadioItem itemWithTitle:SetTitle(@"type") value:self.clientModel.clientType==0?SetTitle(@"customer"):SetTitle(@"supplier") selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        NSArray *options = @[SetTitle(@"customer"),SetTitle(@"supplier")];
        
        ClientTypeVC *typeVC = [[ClientTypeVC alloc]initWithNibName:nil bundle:nil item:item options:options multipleChoice:NO completionHandler:^(RETableViewItem *selectedItem){
            [weakSelf.navigationController popViewControllerAnimated:YES];
            DLog(@"selectedItem = %@",selectedItem.title);
            
            if ([selectedItem.title isEqualToString:SetTitle(@"customer")]) {
                weakSelf.clientModel.clientType=0;
                
                [_manager addSection:section21];
                
                [_manager.tableView reloadData];
            }else {
                weakSelf.clientModel.clientType=1;
                
                [_manager removeSection:section21];
                
                [_manager.tableView reloadData];
            }
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }];
        typeVC.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:typeVC animated:YES];
        SafeRelease(typeVC);
    }];
    typeItem.enabled = self.isNew;
    [section1 addItem:typeItem];

    
    // Add a section
    RETableViewSection *section2 = [RETableViewSection section];
    [_manager addSection:section2];
    section2.headerHeight = 10;
    
    //名字
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"name") value:self.clientModel.clientName?self.clientModel.clientName:@"" placeholder:SetTitle(@"product_required")];
    nameItem.onChange = ^(RETextItem *item){
        [weakSelf checkData];
        weakSelf.clientModel.clientName = item.value;
    };
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.validators = @[@"presence"];
    [section2 addItem:nameItem];
    
    //电话
    RETextItem *phoneItem = [RETextItem itemWithTitle:SetTitle(@"log_phone") value:self.clientModel.clientPhone?self.clientModel.clientPhone:@"" placeholder:SetTitle(@"product_set")];
    phoneItem.onChange = ^(RETextItem *item){
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            [weakSelf checkData];
            weakSelf.clientModel.clientPhone = item.value;
        }else {
            item.textFieldColor = kDeleteColor;
        }
    };
    phoneItem.keyboardType = UIKeyboardTypeNumberPad;
    phoneItem.alignment = NSTextAlignmentRight;
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
    
    //备注
    RETextItem *markItem = [RETextItem itemWithTitle:SetTitle(@"product_mark") value:self.clientModel.clientRemark?self.clientModel.clientRemark:@"" placeholder:SetTitle(@"product_set")];
    markItem.onChange = ^(RETextItem *item){
        weakSelf.clientModel.clientRemark = item.value;
    };
    markItem.alignment = NSTextAlignmentRight;
    [section2 addItem:markItem];
    
    if (!self.isNew && self.clientModel.clientType==1) {
    }else {
        [_manager addSection:section21];
    }
    
    section21.headerHeight = 10;
    //等级
    RELevelItem *levelItem = [RELevelItem itemWithTitle:SetTitle(@"level") index:self.clientModel.clientLevel];
    levelItem.selectionStyle = UITableViewCellSelectionStyleNone;
    levelItem.onChange = ^(RELevelItem *item){
        weakSelf.clientModel.clientLevel = item.currentIndex;
        [item reloadRowWithAnimation:UITableViewRowAnimationNone];
    };
    [section21 addItem:levelItem];
    
    //显示价格
    REBoolItem *displayItem = [REBoolItem itemWithTitle:SetTitle(@"price_display") value:self.clientModel.isShowPrice switchValueChangeHandler:^(REBoolItem *item) {
        weakSelf.clientModel.isShowPrice = item.value;
    }];
    [section21 addItem:displayItem];
    
    //显示库存
    REBoolItem *stockItem = [REBoolItem itemWithTitle:SetTitle(@"stock_display") value:self.clientModel.isShowStock switchValueChangeHandler:^(REBoolItem *item) {
        weakSelf.clientModel.isShowStock = item.value;
    }];
    [section21 addItem:stockItem];
    
//    //分次支付
//    REBoolItem *mutableItem = [REBoolItem itemWithTitle:SetTitle(@"order_mutable") value:self.clientModel.isMutable switchValueChangeHandler:^(REBoolItem *item) {
//        weakSelf.clientModel.isMutable = item.value;
//    }];
//    [section21 addItem:mutableItem];
    
    
    
    if (self.isEditing) {
        RETableViewSection *section3 = [RETableViewSection section];
        [self.manager addSection:section3];
        section3.headerHeight = 10;
        RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:SetTitle(@"order_delete") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
            [item deselectRowAnimated:YES];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"ConfirmDelete") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [weakSelf addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                
                AVObject *obj = [AVObject objectWithClassName:@"Client" objectId:weakSelf.clientModel.clientId];
                
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                   
                    if (succeeded) {
                        [[LCCKConversationService sharedInstance] sendWelcomeMessageToPeerId:weakSelf.clientModel.clientName text:@"xiaxian" block:^(BOOL succeeded, NSError *error) {
                            
                        }];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:weakSelf.clientModel.clientName];
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    }
                    
                }];
                
//                [obj setObject:[NSNumber numberWithBool:true] forKey:@"isMutable"];
//                [obj setObject:[NSNumber numberWithBool:true] forKey:@"disable"];
//                
//                [obj saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
//                    if (succeeded) {
//                        
//                    }
//                }];
            }];
            [weakSelf addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
            [weakSelf presentViewController:alert animated:YES completion:nil];
            
        }];
        buttonItem.titleColor = kDeleteColor;
        buttonItem.textAlignment = NSTextAlignmentCenter;
        [section3 addItem:buttonItem];
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
    
    AVQuery *query = [AVQuery queryWithClassName:@"Client"];
    [query whereKey:@"clientName" equalTo:self.clientModel.clientName];
    if ([Utility checkString:self.clientModel.clientId] && self.isEditing) {
        [query whereKey:@"58301bbf570c35006c0370bf" notEqualTo:self.clientModel.clientId];
    }
    NSInteger count = [query countObjects];
    if (count>0 || [self.clientModel.clientName isEqualToString:[AVUser currentUser].username]) {
        [PopView showWithImageName:nil message:SetTitle(@"cus_name_error")];
        
        return;
    }
    
    
    if ([Utility checkString:self.clientModel.clientId] && self.isEditing){//编辑客户
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:SetTitle(@"client_editing") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.clientModel.clientId];
                post[@"clientType"] = @(weakSelf.clientModel.clientType);
                if (weakSelf.clientModel.clientType==0) {
                    post[@"clientLevel"] = @(weakSelf.clientModel.clientLevel);
                    post[@"isShowPrice"] = @(weakSelf.clientModel.isShowPrice);
                    post[@"isShowStock"] = @(weakSelf.clientModel.isShowStock);
                    post[@"isMutable"] = @(weakSelf.clientModel.isMutable);
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
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
    }else {//创建客户
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:self.clientModel.clientType==0?SetTitle(@"client_creat"):SetTitle(@"supplier_creat") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
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
                            if (weakSelf.addHandler) {
                                weakSelf.addHandler();
                            }
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                });
            });
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
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
