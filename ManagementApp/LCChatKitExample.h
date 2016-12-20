//
//  LCChatKitExample.m
//  LeanCloudChatKit-iOS
//
//  v0.7.20 Created by ElonChan (微信向我报BUG:chenyilong1010) on 16/2/24.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCChatKit.h"

@interface LCChatKitExample : NSObject

+(LCChatKitExample *)sharedInstance;

#pragma mark - SDK Life Control
#pragma mark - quick start 使用下面的函数即可完成从程序启动到登录再到登出的完整流程

/// ----------------------------------------------------------------------------------------------------------
///---注意：在`-[AppDelegate didFinishLaunchingWithOptions:]`
///等函数中调用下面这几个基础的入口胶水函数，可完成初步的集成。
///
///---注意：进一步地，胶水代码中包含了特地设置的#warning，请仔细阅读这些warning的注释，根据实际情况调整代码，以符合你的需求。
/// ----------------------------------------------------------------------------------------------------------

/*!
 *  入口胶水函数：初始化入口函数
 *
 *  程序完成启动，在appdelegate中的 `-[AppDelegate didFinishLaunchingWithOptions:]`
 * 一开始的地方调用.
 */
+ (void)invokeThisMethodInDidFinishLaunching;

/*!
 * Invoke this method in `-[AppDelegate
 * appDelegate:didRegisterForRemoteNotificationsWithDeviceToken:]`.
 */
+ (void)invokeThisMethodInDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/*!
 * invoke This Method In `-[AppDelegate application:didReceiveRemoteNotification:]`
 */
+ (void)invokeThisMethodInApplication:(UIApplication *)application
         didReceiveRemoteNotification:(NSDictionary *)userInfo;

/*!
 *  入口胶水函数：登入入口函数
 *
 *  用户登录时调用
 */
+ (void)invokeThisMethodAfterLoginSuccessWithClientId:(NSString *)clientId
                                              success:(LCCKVoidBlock)success
                                               failed:(LCCKErrorBlock)failed;
/*!
 *  入口胶水函数：登出入口函数
 *
 *  用户即将退出登录时调用
 */
+ (void)invokeThisMethodBeforeLogoutSuccess:(LCCKVoidBlock)success failed:(LCCKErrorBlock)failed;

+ (void)invokeThisMethodInApplicationWillResignActive:(UIApplication *)application;
+ (void)invokeThisMethodInApplicationWillTerminate:(UIApplication *)application;

- (void)exampleInit;
@end
