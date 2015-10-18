//
//  Utility.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "Utility.h"

@implementation Utility

#pragma mark - 判断字符串是否为空

+(BOOL)checkString:(NSString *)string {
    if (string.length==0) {
        return NO;
    }
    if (string == nil || string == NULL) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return NO;
    }
    return YES;
}

#pragma mark - 判断接口

+(void)interfaceWithStatus:(NSInteger)status msg:(NSString *)msg {
    if (status==0) {
        
    }else if (status==101 || status==100) {
//        [[WQLocalDB sharedWQLocalDB] deleteLocalUserWithCompleteBlock:^(BOOL finished) {
//            [[Utility sharedService].appDel.xmppManager getOffLineMessage];
//            [[Utility sharedService].appDel.xmppManager goOffline];
//            [[Utility sharedService].appDel.xmppManager teardownStream];
//            [Utility sharedService].appDel.xmppManager = nil;
//            
//            [[Utility sharedService].appDel saveMessageData];
//            [Utility dataShareClear];
//            
//            [[Utility sharedService].appDel showRootVC];
//        }];
    }
    [PopView showWithImageName:@"error" message:msg];
}

+(UIImage *)getImgWithImageName:(NSString *)imgName{
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:@".png"]];
}
@end
