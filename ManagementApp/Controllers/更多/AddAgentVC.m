//
//  AddAgentVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AddAgentVC.h"
#import "RETableViewManager.h"

@interface AddAgentVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *dayNum;
@property (nonatomic, copy) NSString *mark;
@end

@implementation AddAgentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dayNum = @"0";
    [self setNavBarView];
    
    [self checkData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"new_agent") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    [self.view addSubview:self.navBarView];
    
    [self setTableView];
    
    [Utility setExtraCellLineHidden:self.tableView];
}

-(void)setTableView {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    // Create manager
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    __weak __typeof(self)weakSelf = self;
    
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    
    //名字
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"name") value:@"" placeholder:SetTitle(@"product_required")];
    nameItem.onChange = ^(RETextItem *item){
        weakSelf.name = item.value;
        [weakSelf checkData];
    };
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.validators = @[@"presence"];
    [section addItem:nameItem];
    
    //电话
    RETextItem *phoneItem = [RETextItem itemWithTitle:SetTitle(@"phone") value:@"" placeholder:SetTitle(@"product_required")];
    phoneItem.onChange = ^(RETextItem *item){
        if ([Utility predicateText:item.value regex:@"^[0-9]*$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.phone = item.value;
            [weakSelf checkData];
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    phoneItem.keyboardType = UIKeyboardTypeNumberPad;
    phoneItem.alignment = NSTextAlignmentRight;
    phoneItem.validators = @[@"presence"];
    [section addItem:phoneItem];
    
    //邮箱
    RETextItem *emailItem = [RETextItem itemWithTitle:SetTitle(@"email") value:@"" placeholder:SetTitle(@"product_set")];
    emailItem.onChange = ^(RETextItem *item){
        if ([Utility predicateText:item.value regex:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.email = item.value;
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    emailItem.keyboardType = UIKeyboardTypeEmailAddress;
    emailItem.alignment = NSTextAlignmentRight;
    emailItem.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [section addItem:emailItem];
    
    
    //备注
    RETextItem *markItem = [RETextItem itemWithTitle:SetTitle(@"product_mark") value:@"" placeholder:SetTitle(@"product_set")];
    markItem.onChange = ^(RETextItem *item){
        weakSelf.mark = item.value;
    };
    markItem.alignment = NSTextAlignmentRight;
    [section addItem:markItem];
    
    //天数
    
    RECompanyDayItem *dayIten = [RECompanyDayItem itemWithTitle:SetTitle(@"agent_day") value:self.dayNum placeholder:@"0"];
    
    dayIten.onEndEditing = ^(RETextItem *item) {
        weakSelf.dayNum = item.value;
        [weakSelf checkData];
    };
    dayIten.cellHeight = 60;
    [section addItem:dayIten];
}

-(void)checkData {
    NSArray *managerErrors = self.manager.errors;
    if (managerErrors.count > 0) {
        self.navBarView.rightEnable = NO;
    }else {
        
        if ([self.dayNum integerValue]==0) {
            self.navBarView.rightEnable = NO;
        }else {
            self.navBarView.rightEnable = YES;
        }
    }
}
#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    [self.view endEditing:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AVObject *post = [AVObject objectWithClassName:@"_User"];
    
    post[@"username"] = self.name;
    post[@"password"] = @"123456";
    post[@"email"] = self.email;
    post[@"mobilePhoneNumber"] = self.phone;
    post[@"mark"] = self.mark;
    [post setObject:[NSNumber numberWithInteger:[self.dayNum integerValue]] forKey:@"day"];
    
    AVACL *acl = [AVACL ACL];
    [acl setReadAccess:YES forUser:[AVUser currentUser]];
    [acl setWriteAccess:YES forUser:[AVUser currentUser]];
    [post setACL:acl];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if (succeeded) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [PopView showWithImageName:@"error" message:[error localizedDescription]];
        }
    }];

}

@end
