//
//  ProductPriceModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///商品价格

@interface ProductPriceModel : NSObject

@property (nonatomic, assign) CGFloat aPrice;
@property (nonatomic, assign) CGFloat bPrice;
@property (nonatomic, assign) CGFloat cPrice;
@property (nonatomic, assign) CGFloat dPrice;

///选择的价格,0=a,1=b,2=c,3=d   -1=未选
@property (nonatomic, assign) NSInteger selected;
@end
