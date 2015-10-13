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
@end
