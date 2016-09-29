//
//  OrderStockModel.h
//  BApp
//
//  Created by 邱成西 on 16/1/11.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderStockModel : NSObject

@property (nonatomic, copy) NSString *orderStockId;

@property (nonatomic, assign) NSInteger num;

@property (nonatomic, copy) NSString *colorName;

@property (nonatomic, copy) NSString *header;

@property (nonatomic, copy) NSString *oid;

@property (nonatomic, copy) NSString *pcode;

@property (nonatomic, assign) CGFloat price;

@property (nonatomic, copy) NSString *clientName;

@property (nonatomic, strong) NSDate *creat;

@property (nonatomic, copy) NSString *timeString;

@property (nonatomic, assign) CGFloat purchasePrice;

@property (nonatomic, assign) NSInteger clientLevel;
@end
