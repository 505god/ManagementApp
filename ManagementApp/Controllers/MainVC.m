//
//  MainVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()<TabbarViewDelegate>

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置tabBarView
    [self.view addSubview:self.tabBarView];
    
    if ([DataShare sharedService].isPushing) {
        if ([DataShare sharedService].pushType == WQPushTypeOrder) {
            self.tabBarView.currentPage = self.currentPage = 2;
        }else if ([DataShare sharedService].pushType == WQPushTypeClient) {
            self.tabBarView.currentPage = self.currentPage = 1;
        }else {
            self.tabBarView.currentPage = self.currentPage = 0;
        }
    }else {
        self.tabBarView.currentPage = self.currentPage = 0;
    }
    
    
    //设置子controller
    self.currentViewController = [self.childenControllerArray objectAtIndex:self.currentPage];
    if (self.currentViewController) {
        [self addOneController:self.currentViewController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter/setter

-(TabbarView *)tabBarView {
    if (!_tabBarView) {
        _tabBarView = [[TabbarView alloc]initWithFrame: (CGRect){0,self.view.height-TabbarHeight,[UIScreen mainScreen].bounds.size.width,TabbarHeight}];
        _tabBarView.delegate = self;
        [_tabBarView defaultSelected];
    }
    return _tabBarView;
}

-(void)setChildenControllerArray:(NSArray *)childenControllerArray{
    if (_childenControllerArray != childenControllerArray && childenControllerArray&& childenControllerArray.count > 0) {
        for (UIViewController *controller in childenControllerArray) {
            [controller willMoveToParentViewController:self];
            [self addChildViewController:controller];
            [controller didMoveToParentViewController:self];
        }
    }
    _childenControllerArray = childenControllerArray;
}

-(void)setCurrentPageVC:(NSInteger)page {
    if (self.currentPage != page) {
        [self.tabBarView defaultSelected];
        self.currentPage = page;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:self.currentPage]];
    }
}

#pragma mark - 子controller之间切换
-(void)addOneController:(UIViewController*)childController{
    if (!childController) {
        return;
    }
    [childController willMoveToParentViewController:self];
    childController.view.frame = (CGRect){0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height-TabbarHeight};
    [self.view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.tabBarView];
}

-(void)changeFromController:(UIViewController*)from toController:(UIViewController*)to{
    if (!from || !to) {
        return;
    }
    if (from == to) {
        return;
    }
    
    to.view.frame = (CGRect){0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height-TabbarHeight};
    [self transitionFromViewController:from toViewController:to duration:0 options:UIViewAnimationOptionTransitionNone animations:^{
        
    } completion:^(BOOL finished) {
        self.currentViewController = to;
        [self.view bringSubviewToFront:self.tabBarView];
    }];
}

#pragma mark - 底部代理

-(void)tabBar:(TabbarView*)tabBarView selectedItem:(NSInteger)itemType {
    if (itemType < self.childenControllerArray.count) {
        self.currentPage = itemType;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:itemType]];
    }
}

#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}
@end
