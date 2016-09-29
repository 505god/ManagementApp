//
//  StatisticsVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/11/3.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "StatisticsVC.h"

@interface StatisticsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation StatisticsVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"Statistics") image:nil];
    [self.view addSubview:self.navBarView];
    
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStyleGrouped];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
}


@end
