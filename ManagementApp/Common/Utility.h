//
//  Utility.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///公共类方法

@interface Utility : NSObject

#pragma mark - 判断字符串是否为空
+(BOOL)checkString:(NSString *)string;

#pragma mark - 判断接口
+(void)interfaceWithStatus:(NSInteger)status msg:(NSString *)msg;

#pragma mark - 获取本地图片
+(UIImage *)getImgWithImageName:(NSString *)imgName;

#pragma mark - 隐藏UITableView多余的分割线
+ (void)setExtraCellLineHidden: (UITableView *)tableView;

#pragma mark -  对图片data大小比例压缩
+(UIImage *)dealImageData:(UIImage *)image;

#pragma mark -  正则判断
+(BOOL)predicateText:(NSString *)text regex:(NSString *)regex;
@end
