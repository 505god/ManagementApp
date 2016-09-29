//
//  AgentDetailVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AgentDetailVC.h"
#import "RETableViewManager.h"
#import "UIImageView+WebCache.h"

#import "AFNetworking.h"
#import "NSString+md5.h"

#define APPID @"4buRKUuDv5oI11CpPtogkX6X"
#define MASTERKEY @"IgRij0kYWTaOQcgvO1SY8nEo"

@interface AgentDetailVC ()<RETableViewManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, copy) NSString *dayNum;

@end

@implementation AgentDetailVC

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
    [self.navBarView setTitle:SetTitle(@"detail") image:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    
    [self.view addSubview:self.navBarView];
}

-(UIView *)headerViewUI {
    CGFloat height = 150;
    
    UIView *view = [[UIView alloc]initWithFrame:(CGRect){0,0,[UIScreen mainScreen].bounds.size.width,height}];
    
    UIImageView *headerImg = [[UIImageView alloc]initWithFrame:(CGRect){([UIScreen mainScreen].bounds.size.width-120)/2,(height-120)/2,120,120}];
    headerImg.layer.cornerRadius = 8;
    headerImg.layer.masksToBounds = YES;
    headerImg.contentMode = UIViewContentModeScaleAspectFill;
    [headerImg sd_setImageWithURL:[NSURL URLWithString:self.model.userHead] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    
    [view addSubview:headerImg];
    
    return view;
}


-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    
    // Create manager
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    _manager.delegate = self;
    RETableViewSection *section1 = [RETableViewSection section];
    section1.headerView = [self headerViewUI];
    [_manager addSection:section1];
    
    __weak __typeof(self)weakSelf = self;
    
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"name") value:self.model.userName placeholder:SetTitle(@"product_required")];
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.enabled = NO;
    [section1 addItem:nameItem];
    
    
    RERadioItem *pwdItem = [RERadioItem itemWithTitle:SetTitle(@"phone") value:self.model.phone selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weakSelf.model.phone]];
    }];
    [section1 addItem:pwdItem];
    
    
    RETextItem *nameItem3 = [RETextItem itemWithTitle:SetTitle(@"email") value:self.model.email placeholder:SetTitle(@"product_set")];
    nameItem3.alignment = NSTextAlignmentRight;
    nameItem3.enabled = NO;
    [section1 addItem:nameItem3];
    
    
    RECompanyDayItem *dayIten = [RECompanyDayItem itemWithTitle:SetTitle(@"agent_day") value:self.model.dayNumber placeholder:@"0"];
    
    dayIten.onEndEditing = ^(RETextItem *item) {
        weakSelf.dayNum = [NSString stringWithFormat:@"%ld",([item.value integerValue]-[self.model.dayNumber integerValue])];
        
        [weakSelf checkData];
    };
    dayIten.cellHeight = 60;
    [section1 addItem:dayIten];
}

-(void)checkData {
    if ([self.dayNum integerValue] <= [self.model.dayNumber integerValue]) {
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
    
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.leancloud.cn"]];
    [Client setDefaultHeader:@"Content-Type" value:@"application/json"];
    [Client setDefaultHeader:@"X-LC-Id" value:APPID];
    [Client setDefaultHeader:@"X-LC-Key" value:[NSString stringWithFormat:@"%@,master",MASTERKEY]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:([self.dayNum integerValue]+self.model.day)] forKey:@"day"];
    NSString* path = [NSString stringWithFormat:@"/1.1/classes/_User/%@",self.model.userId];
    
    [Client putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        weakSelf.model.day = [weakSelf.dayNum integerValue]+weakSelf.model.day;
        weakSelf.dayNum = nil;
        
        if (weakSelf.updateHandler) {
            weakSelf.updateHandler (weakSelf.idxPath,weakSelf.model);
        }
        
        [PopView showWithImageName:@"error" message:SetTitle(@"update_success")];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 150;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
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
