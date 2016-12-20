//
//  BaseVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/10.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavBarView.h"

@interface BaseVC : UIViewController

//导航栏
@property (nonatomic, strong) NavBarView *navBarView;


//导航栏代理
-(void)leftBtnClickByNavBarView:(NavBarView *)navView;
-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag;

- (void)addActionTarget:(UIAlertController *)alertController title:(NSString *)title color:(UIColor *)color action:(void(^)(UIAlertAction *action))actionTarget;


-(void)addCancelActionTarget:(UIAlertController*)alertController title:(NSString *)title;


-(void)addCancelActionTarget:(UIAlertController*)alertController title:(NSString *)title action:(void(^)(UIAlertAction *action))actionTarget;
@end
