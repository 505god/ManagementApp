//
//  TabbarView.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TabBarItem.h"

@protocol TabbarViewDelegate;

@interface TabbarView : UIView

@property (nonatomic, strong) TabBarItem *item0;
@property (nonatomic, strong) TabBarItem *item1;
@property (nonatomic, strong) TabBarItem *item2;
@property (nonatomic, strong) TabBarItem *item3;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) id<TabbarViewDelegate>delegate;

//取消所有选中
-(void)defaultSelected;
@end

@protocol TabbarViewDelegate <NSObject>

-(void)tabBar:(TabbarView*)tabBarView selectedItem:(NSInteger)itemType;

@end