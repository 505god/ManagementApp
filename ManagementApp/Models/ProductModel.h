//
//  ProductModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SortModel.h"
#import "ProductStockModel.h"
#import "MaterialModel.h"

@interface ProductModel : NSObject

///商品id
@property (nonatomic, strong) NSString *productId;

///商品详情
@property (nonatomic, strong) NSString *productDetails;

///商品货号必填
@property (nonatomic, strong) NSString *productCode;
///进货价
@property (nonatomic, assign) CGFloat purchaseprice;

///盈利状态 －1=未设置进货价 0=亏本  1= 盈利
@property (nonatomic, assign) NSInteger profitStatus;

///盈利
@property (nonatomic, assign) CGFloat profit;

///包装数
@property (nonatomic, assign) NSInteger packageNum;


@property (nonatomic, assign) NSInteger discountType;
@property (nonatomic, assign) CGFloat discount;


///名称
@property (nonatomic, strong) NSString *productName;

///材质
@property (nonatomic, strong) MaterialModel *materialModel;

///分类
@property (nonatomic, strong) SortModel *sortModel;

///备注
@property (nonatomic, strong) NSString *productMark;

///上架
@property (nonatomic, assign) BOOL isDisplay;

///热卖
@property (nonatomic, assign) BOOL isHot;

///商品库存
@property (nonatomic, strong) NSMutableArray *productStockArray;

///销售量
@property (nonatomic, assign) NSInteger saleCount;

///库存数量
@property (nonatomic, assign) NSInteger stockCount;

///图片
@property (nonatomic, strong) NSString *picHeader;

///商品价格必填
@property (nonatomic, assign) CGFloat aPrice;
@property (nonatomic, assign) CGFloat bPrice;
@property (nonatomic, assign) CGFloat cPrice;
@property (nonatomic, assign) CGFloat dPrice;
///选择的价格,0=a,1=b,2=c,3=d   -1=未选
@property (nonatomic, assign) NSInteger selected;



///是否设置库存预警
@property (nonatomic, assign) BOOL isSetting;
///总的数量
@property (nonatomic, assign) NSInteger totalNum;
///单个数量
@property (nonatomic, assign) NSInteger singleNum;

+(ProductModel *)initWithObject:(AVObject *)object ;


@property (nonatomic, strong) NSString *sortId;
@property (nonatomic, strong) NSString *materialId;


//是否库存预警
@property (nonatomic, assign) BOOL isWarning;
@end
