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
        if ([DataShare sharedService].pushType==2 || [DataShare sharedService].pushType==4 || [DataShare sharedService].pushType==5 || [DataShare sharedService].pushType==6) {
            self.tabBarView.currentPage = self.currentPage = 2;
        }else if ([DataShare sharedService].pushType == WQPushTypeClient || [DataShare sharedService].pushType == WQPushTypeMsg) {
            self.tabBarView.currentPage = self.currentPage = 1;
        }else {
            self.tabBarView.currentPage = self.currentPage = 0;
        }
        
        [PopView showWithImageName:nil message:[DataShare sharedService].pushText];
    }else {
        self.tabBarView.currentPage = self.currentPage = 0;
    }
    
    
    //设置子controller
    self.currentViewController = [self.childenControllerArray objectAtIndex:self.currentPage];
    if (self.currentViewController) {
        [self addOneController:self.currentViewController];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotification:) name:@"pushNotification" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:LCCKNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:LCCKNotificationUnreadsUpdated object:nil];
    
    [self getMessageUnread];
}

-(void)refresh {
    [self getMessageUnread];
}

-(void)getMessageUnread {
    //加载聊天记录
    QWeakSelf(self);
    [[LCCKConversationListService sharedInstance] findRecentConversationsWithBlock:^(NSArray *conversations, NSInteger totalUnreadCount, NSError *error) {
        
        [weakself.tabBarView.item1.notificationHub setCount:totalUnreadCount==0?-1:(int)totalUnreadCount];
    }];
}

-(void)pushNotification:(NSNotification *)notification {
    
    int type = [[notification object]intValue];
    
    [self.tabBarView defaultSelected];
    
    if (type==1 || type==3) {
        if (self.currentPage==1) {
            return;
        }
        [self tabBar:self.tabBarView selectedItem:1];
        self.tabBarView.item1.isSelected = YES;
        self.currentPage=1;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:self.currentPage]];
    }else if (type==2 || type==4 || type==5 || type==6){
        if (self.currentPage==2) {
            return;
        }
        [self tabBar:self.tabBarView selectedItem:2];
        self.tabBarView.item2.isSelected = YES;
        self.currentPage=2;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:self.currentPage]];
    }else if (type==7) {
        if (self.currentPage==0) {
            return;
        }
        [self tabBar:self.tabBarView selectedItem:0];
        self.tabBarView.item0.isSelected = YES;
        self.currentPage=0;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:self.currentPage]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter/setter

-(TabbarView *)tabBarView {
    if (!_tabBarView) {
        _tabBarView = [[TabbarView alloc]initWithFrame: (CGRect){0,[UIScreen mainScreen].bounds.size.height-TabbarHeight,[UIScreen mainScreen].bounds.size.width,TabbarHeight}];
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
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}
@end
