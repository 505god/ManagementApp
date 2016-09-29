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

#import "Reachability.h"

#import "LeanChatCoreDataManager.h"

@interface AppDelegate ()

@property (strong, nonatomic) Reachability *hostReach;//网络监听所用

@end

@implementation AppDelegate

+ (AppDelegate*)shareInstance {
    return (AppDelegate*)([UIApplication sharedApplication].delegate);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarStyle:UIStatusBarStyleLightContent];    
    
    // 配置
    [LeanChatManager setupApplication];
    
    ///－－－－－－－－－－－－－－－－－－－－推送
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    //－－－－－－－－－－－－－－－－－－－－开启网络状况的监听
    
    _isReachable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
    [_hostReach startNotifier];  //开始监听，会启动一个run loop
    
    //－－－－－－－－－－－－－－－－－－－－判读进入app来源
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"isOn"];
    [defaults synchronize];
    
    [DataShare sharedService].isPushing = NO;
    [DataShare sharedService].pushType = WQPushTypeNone;
    
    NSDictionary *pushDict = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (pushDict) {
        [DataShare sharedService].isPushing = YES;
        [DataShare sharedService].pushType = [pushDict[@"type"] integerValue];
    }
    
    //－－－－－－－－－－－－－－－－－－－－VC
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    InitVC *initVC = LOADVC(@"InitVC");
    
    self.window.rootViewController = initVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:2 forKey:@"isOn"];
    [defaults synchronize];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self saveMessageData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [self saveMessageData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger isOn = [defaults integerForKey:@"isOn"];
    if (isOn==2) {
        [defaults setInteger:1 forKey:@"isOn"];
        [defaults synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"isOn"];
    [defaults synchronize];

    [[LeanChatManager manager] close:^(BOOL succeeded, NSError *error) {
        
    }];
    [Utility dataShareClear];
    [[LeanChatCoreDataManager manager]saveContext];
    [self saveMessageData];
}

-(void)saveMessageData {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *path = [Utility returnPath];
    //保存未读消息的数组
    NSString *filenameMessage = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"message_%@.plist",[AVUser currentUser].username]];
    if ([fileManage fileExistsAtPath:filenameMessage]) {
        [fileManage removeItemAtPath:filenameMessage error:nil];
    }
    [NSKeyedArchiver archiveRootObject:[DataShare sharedService].unreadMessageDic toFile:filenameMessage];
}

-(void)getMessageData {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *path = [Utility returnPath];
    NSString *filenameMessage = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"message_%@.plist",[AVUser currentUser].username]];
    
    if ([fileManage fileExistsAtPath:filenameMessage]) {
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:filenameMessage];
        [DataShare sharedService].unreadMessageDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
}
#pragma mark -
#pragma mark - 推送

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceProfile:@"MAPP"];
    [currentInstallation setBadge:0];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSInteger isOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"isOn"];
    int type = [[userInfo objectForKey:@"type"]intValue];
    if (type==WQPushTypeClient) {//新品上市
        if (isOn == 2) {//app从后台进入前台
            [PopView showWithImageName:@"error" message:SetTitle(@"new_client")];
        }else {
            [DataShare sharedService].pushType = type;
            [DataShare sharedService].isPushing = YES;
        }
    }else if (type==WQPushTypeOrder) {
        if (isOn == 2) {//app从后台进入前台
            [PopView showWithImageName:@"error" message:SetTitle(@"new_order")];
        }else {
            [DataShare sharedService].pushType = WQPushTypeOrder;
            [DataShare sharedService].isPushing = YES;
        }
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark -
#pragma mark - 网络

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    if(status == NotReachable) {
        self.isReachable = NO;
    }else {
        self.isReachable = YES;
    }
}

#pragma mark -
#pragma mark - 加载VC

///type: 0=登陆页面  1=首页
-(void)showRootVCWithType:(NSInteger)type {
    if (type==1) {
        [self getMessageData];
        
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
        
        if (type==2) {
            [PopView showWithImageName:@"error" message:SetTitle(@"Company_expire")];
        }
    }
}

@end
