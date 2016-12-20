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
    self.edgesForExtendedLayout = UIRectEdgeNone;
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


//添加对应的title    这个方法也可以传进一个数组的titles  我只传一个是为了方便实现每个title的对应的响应事件不同的需求不同的方法
- (void)addActionTarget:(UIAlertController *)alertController title:(NSString *)title color:(UIColor *)color action:(void(^)(UIAlertAction *action))actionTarget
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        actionTarget(action);
    }];
//    [action setValue:color forKey:@"_titleTextColor"];
    [alertController addAction:action];
}

// 取消按钮
-(void)addCancelActionTarget:(UIAlertController*)alertController title:(NSString *)title action:(void(^)(UIAlertAction *action))actionTarget
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        actionTarget(action);
    }];
//    [action setValue:kDeleteColor forKey:@"_titleTextColor"];
    [alertController addAction:action];
}

// 取消按钮
-(void)addCancelActionTarget:(UIAlertController*)alertController title:(NSString *)title
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
//    [action setValue:kDeleteColor forKey:@"_titleTextColor"];
    [alertController addAction:action];
}

@end
