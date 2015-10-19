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

#pragma mark - 获取本地图片

+(UIImage *)getImgWithImageName:(NSString *)imgName{
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:@".png"]];
}

#pragma mark - 隐藏UITableView多余的分割线

+ (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark -  对图片data大小比例压缩

+(UIImage *)dealImageData:(UIImage *)image {
    
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 200*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return [UIImage imageWithData:imageData];
}

@end
