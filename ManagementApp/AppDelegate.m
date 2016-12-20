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
#import <CommonCrypto/CommonDigest.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif

//#define kApplicationId @"j39OUXHrhrHTm8RTjvJjxcGU-MdYXbMMI"
//#define kClientKey @"WMQBhuXeKKxnNdWi0cP3nCpT"



@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (strong, nonatomic) Reachability *hostReach;//网络监听所用

@end

@implementation AppDelegate

+ (AppDelegate*)shareInstance {
    return (AppDelegate*)([UIApplication sharedApplication].delegate);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:kThemeColor];
    [[UINavigationBar appearance] setTintColor:kWhiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kWhiteColor,NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    
    [NSThread detachNewThreadSelector:@selector(loopMethod) toTarget:self withObject:nil];
    // 配置
    [LCChatKitExample invokeThisMethodInDidFinishLaunching];
    [LCChatKit setAppId:kApplicationId appKey:kClientKey];
    
    ///－－－－－－－－－－－－－－－－－－－－推送
    if (Platform >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate=self;
        UNAuthorizationOptions types10=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击
            } else {
                //点击不允许
            }
        }];
    }else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        
    }
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
        [DataShare sharedService].pushText = [[pushDict objectForKey:@"aps"] objectForKey:@"alert"];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
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

    [Utility dataShareClear];
}
#pragma mark -
#pragma mark - 推送

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken constructingInstallationWithBlock:^(AVInstallation *currentInstallation) {
        currentInstallation.deviceProfile = @"MAPP";
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSInteger isOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"isOn"];
    
    if (isOn==1) {
        //前台
        if (self.messageTo && [self.messageTo isEqualToString:[DataShare sharedService].clientObject.clientName]) {
        }else{
            [PopView showWithImageName:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
        }
        
    }else {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushNotification" object:[userInfo objectForKey:@"type"]];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

//iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    if (self.messageTo && [self.messageTo isEqualToString:[DataShare sharedService].clientObject.clientName]) {
    }else{
        [PopView showWithImageName:nil message:notification.request.content.body];
    }
    
    completionHandler(UNNotificationPresentationOptionAlert);
    
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pushNotification" object:[userInfo objectForKey:@"type"]];
    completionHandler();
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
        UINavigationController *navControl = [[UINavigationController alloc]initWithRootViewController:logVC];
        
        self.window.rootViewController = navControl;
    }
}

//定时更新信息
- (void)loopMethod {
    [NSTimer scheduledTimerWithTimeInterval:60*30 target:self selector:@selector(requestIsHaveReview) userInfo:nil repeats:YES];
    
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    
    [loop run];
}

-(void)requestIsHaveReview {
    AVUser *user = [AVUser currentUser];
    
    if (user != nil) {
        [[AVUser currentUser] refresh];
        
        UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
        
        [DataShare sharedService].userObject = user;
        
        
        if ([DataShare sharedService].userObject.isExpire && [DataShare sharedService].userObject.type!=1) {
            [PopView showWithImageName:nil message:SetTitle(@"authority_error")];
        }
    }
}

//登录后保存信息
-(void)saveUserInfo {    
    //保存到单列
    UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
    
    [DataShare sharedService].userObject = user;
    
    [LCChatKitExample invokeThisMethodAfterLoginSuccessWithClientId:[DataShare sharedService].userObject.userName success:^{
    } failed:^(NSError *error) {
    }];
    
    //用于推送
    AVInstallation *installation = [AVInstallation currentInstallation];
    [installation setObject:user.userId forKey:@"cid"];
    [installation saveInBackground];
}
@end
