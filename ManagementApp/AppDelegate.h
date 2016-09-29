//
//  AppDelegate.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/10.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL isReachable;//网络是否连接

+ (AppDelegate*)shareInstance;

///type: 0=登陆页面  1=首页
-(void)showRootVCWithType:(NSInteger)type;

@end

