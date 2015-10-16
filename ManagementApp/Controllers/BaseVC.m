//
//  BaseVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/10.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()<NavBarViewDelegate>

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter/setter

-(NavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [[NavBarView alloc]initWithFrame:(CGRect){0,0,[[UIScreen mainScreen] bounds].size.width, 64}];
        _navBarView.navDelegate = self;
    }
    return _navBarView;
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    
}

@end
