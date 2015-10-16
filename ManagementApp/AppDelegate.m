//
//  AppDelegate.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/10.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "AppDelegate.h"
#import "InitVC.h"

#import "LoginVC.h"

#import "ICSDrawerController.h"

#import "SortVC.h"

#import "MainVC.h"
#import "StockVC.h"
#import "ClientVC.h"
#import "OrderVC.h"
#import "OptionsVC.h"


#import "ProductVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate*)shareInstance {
    return (AppDelegate*)([UIApplication sharedApplication].delegate);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    InitVC *initVC = LOADVC(@"InitVC");
    
    self.window.rootViewController = initVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - 加载VC
///type: 0=登陆页面  1=首页
-(void)showRootVCWithType:(NSInteger)type {
    
    
    ProductVC *colorVC = [[ProductVC alloc]init];
    UINavigationController *navControl = [[UINavigationController alloc]initWithRootViewController:colorVC];
    self.window.rootViewController = navControl;
    return;
    
    if (type==1) {
        MainVC *mainVC  = [[MainVC alloc]init];
        
        StockVC *stockVC = LOADVC(@"StockVC");
        stockVC.mainVC = mainVC;
        ClientVC *clientVC = LOADVC(@"ClientVC");
        clientVC.mainVC = mainVC;
        OrderVC *orderVC = LOADVC(@"OrderVC");
        OptionsVC *optionsVC = LOADVC(@"OptionsVC");
        
        mainVC.childenControllerArray = @[stockVC,clientVC,orderVC,optionsVC];
        
        SortVC *sortVC = LOADVC(@"SortVC");
        
        ICSDrawerController *drawer1 = [[ICSDrawerController alloc] initWithLeftViewController:sortVC centerViewController:mainVC];
        UINavigationController *navControl = [[UINavigationController alloc]initWithRootViewController:drawer1];
        
        self.window.rootViewController = navControl;
    }else {
        LoginVC *logVC = LOADVC(@"LoginVC");
        self.window.rootViewController = logVC;
    }
}
@end
