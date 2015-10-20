//
//  REProductItem.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/18.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RETextItem.h"

@interface REProductItem : RETextItem

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIImage *picImg;

@property (nonatomic, strong) NSString *imageString;

///删除
@property (copy, nonatomic) void (^deleteHandler)(REProductItem *item);

///选择图片
@property (copy, nonatomic) void (^selectedPictureHandler)(REProductItem *item);


+ (instancetype)itemWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder image:(UIImage *)image imageString:(NSString *)imageString;

- (id)initWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder image:(UIImage *)image imageString:(NSString *)imageString;
@end
