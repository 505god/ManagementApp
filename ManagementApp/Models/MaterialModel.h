//
//  MaterialModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaterialModel : NSObject

///材质id
@property (nonatomic, strong) NSString *materialId;
///材质名称
@property (nonatomic, strong) NSString *materialName;
///材质下产品数量
@property (nonatomic, assign) NSInteger productCount;


///用于选择材质的时候纪录分类的位置
@property (nonatomic, strong) NSIndexPath *indexPath;

+(MaterialModel *)initWithObject:(AVObject *)object;
@end
