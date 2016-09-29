//
//  SortModel.h
//  ManagementApp
//
//  Created by ydd on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SortModel : NSObject

///分类id
@property (nonatomic, strong) NSString *sortId;
///分类名称
@property (nonatomic, strong) NSString *sortName;
///分类下产品数量
@property (nonatomic, assign) NSInteger productCount;


///用于选择分类的时候纪录分类的位置
@property (nonatomic, strong) NSIndexPath *indexPath;


+(SortModel *)initWithObject:(AVObject *)object;
@end
