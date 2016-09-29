//
//  ProductVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

///添加产品页面

#import "ProductModel.h"

@interface ProductVC : BaseVC

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) ProductModel *productModel;


@end
