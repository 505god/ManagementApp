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
@property (nonatomic, strong) NSString *ProductStockId;

///颜色
@property (nonatomic, strong) ColorModel *colorModel;

///进货价
@property (nonatomic, assign) CGFloat purchaseprice;

///图片
@property (nonatomic, strong) NSString *picHeader;
@property (nonatomic, strong) UIImage *image;

///库存
@property (nonatomic, assign) NSInteger stockNum;

@property (nonatomic, assign) NSInteger num;

@property (nonatomic, assign) NSInteger saleNum;
///上架
@property (nonatomic, assign) BOOL isDisplay;
///热卖
@property (nonatomic, assign) BOOL isHot;
@property (nonatomic, strong) NSString *pcode;
///销量
@property (nonatomic, assign) NSInteger saleANum;
@property (nonatomic, assign) NSInteger saleBNum;
@property (nonatomic, assign) NSInteger saleCNum;
@property (nonatomic, assign) NSInteger saleDNum;

///客户
@property (nonatomic, strong) NSString *clientName;

///时间
@property (nonatomic, strong) NSString *time;

@property (nonatomic, assign) BOOL isExit;

@property (nonatomic, assign) CGFloat aPrice;
@property (nonatomic, assign) CGFloat bPrice;
@property (nonatomic, assign) CGFloat cPrice;
@property (nonatomic, assign) CGFloat dPrice;
///选择的价格,0=a,1=b,2=c,3=d   -1=未选
@property (nonatomic, assign) NSInteger selected;
@property (nonatomic, strong) NSString *colorName;

///是否设置库存预警
@property (nonatomic, assign) BOOL isSetting;
@property (nonatomic, assign) BOOL isWarning;
///单个数量
@property (nonatomic, assign) NSInteger singleNum;

+(ProductStockModel *)initWithObject:(AVObject *)object;
@end
