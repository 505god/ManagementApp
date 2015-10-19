//
//  StockWarningModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///库存预警

@interface StockWarningModel : NSObject

///是否设置库存预警
@property (nonatomic, assign) BOOL isSetting;

///总的数量
@property (nonatomic, assign) NSInteger totalNum;

///单个数量
@property (nonatomic, assign) NSInteger singleNum;
@end
