//
//  NavBarView.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/10.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

//导航栏

@protocol NavBarViewDelegate;

@interface NavBarView : UIView

@property (nonatomic, assign) id<NavBarViewDelegate>navDelegate;

///设置左侧按钮、标题
-(void)setLeftWithImage:(NSString *)imageString title:(NSString *)title;

///设置右侧按钮
-(void)setRightWithArray:(NSArray *)array;

///设置标题
-(void)setTitle:(NSString *)title image:(NSString *)imageString;
@end


@protocol NavBarViewDelegate <NSObject>

-(void)leftBtnClickByNavBarView:(NavBarView *)navView;

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag;

@end