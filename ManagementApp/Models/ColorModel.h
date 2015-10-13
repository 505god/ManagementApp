//
//  ColorModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

//颜色分类

@interface ColorModel : NSObject

///颜色id
@property (nonatomic, assign) NSInteger colorId;
///颜色名称
@property (nonatomic, strong) NSString *colorName;
///颜色下产品数量
@property (nonatomic, assign) NSInteger productCount;

@end
