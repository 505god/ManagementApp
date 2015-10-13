//
//  StockVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "StockVC.h"

@interface StockVC ()

@end

@implementation StockVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"navicon_all")];
    [self.navBarView setRightWithArray:@[@"add_bt",@"search_icon"]];
    [self.view addSubview:self.navBarView];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.mainVC.drawer open];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    
}


@end
