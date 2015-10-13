//
//  MainVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"
#import "TabbarView.h"

#import "ICSDrawerController.h"

@interface MainVC : BaseVC<ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property(nonatomic, weak) ICSDrawerController *drawer;

///底部导航
@property (nonatomic, strong) TabbarView *tabBarView;

//子viewController
@property (nonatomic, assign) NSInteger currentPage;
@property (strong, nonatomic) NSArray *childenControllerArray;
@property (strong, nonatomic) UIViewController *currentViewController;
@end
