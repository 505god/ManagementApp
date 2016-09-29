//
//  PwdVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "PwdVC.h"
#import "RETableViewManager.h"

@interface PwdVC ()<RETableViewManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) NSString *pwd0;
@property (nonatomic, strong) NSString *pwd1;
@property (nonatomic, strong) NSString *pwd2;
@end

@implementation PwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    [self setTableViewUI];
    
    [self checkData];
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"editPwd") image:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    
    [self.view addSubview:self.navBarView];
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    RETableViewSection *section1 = [RETableViewSection section];
    [_manager addSection:section1];
    
    __weak __typeof(self)weakSelf = self;
    
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"OriginalPwd") value:@"" placeholder:SetTitle(@"product_required")];
    nameItem.onChange = ^(RETextItem *item){
        weakSelf.pwd0 = item.value;
        [weakSelf checkData];
    };
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.validators = @[@"presence"];
    [section1 addItem:nameItem];
    
    RETextItem *nameItem2 = [RETextItem itemWithTitle:SetTitle(@"NewPwd") value:@"" placeholder:SetTitle(@"product_required")];
    nameItem2.onChange = ^(RETextItem *item){
        weakSelf.pwd1 = item.value;
        [weakSelf checkData];
    };
    nameItem2.alignment = NSTextAlignmentRight;
    nameItem2.validators = @[@"presence"];
    [section1 addItem:nameItem2];
    
    RETextItem *nameItem3 = [RETextItem itemWithTitle:SetTitle(@"NewAgainPwd") value:@"" placeholder:SetTitle(@"product_required")];
    nameItem3.onChange = ^(RETextItem *item){
        weakSelf.pwd2 = item.value;
        [weakSelf checkData];
    };
    nameItem3.alignment = NSTextAlignmentRight;
    nameItem3.validators = @[@"presence"];
    [section1 addItem:nameItem3];
}

-(void)checkData {
    NSArray *managerErrors = self.manager.errors;
    if (managerErrors.count > 0) {
        self.navBarView.rightEnable = NO;
    }else {
        
        if ([self.pwd1 isEqualToString:self.pwd2]) {
            self.navBarView.rightEnable = YES;
        }else {
            self.navBarView.rightEnable = NO;
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
    [[AVUser currentUser] updatePassword:self.pwd0 newPassword:self.pwd1 block:^(id object, NSError *error) {
        //处理结果
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
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
