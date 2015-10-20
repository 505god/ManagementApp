//
//  ProductStockModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ColorModel.h"

@interface ProductStockModel : NSObject

///id
@property (nonatomic, assign) NSInteger ProductStockId;

///颜色
@property (nonatomic, strong) ColorModel *colorModel;

///图片
@property (nonatomic, strong) NSString *picHeader;
@property (nonatomic, strong) UIImage *image;

///库存
@property (nonatomic, assign) NSInteger stockNum;
@end
