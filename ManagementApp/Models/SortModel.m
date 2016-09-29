//
//  SortModel.m
//  ManagementApp
//
//  Created by ydd on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "SortModel.h"

@implementation SortModel

+(SortModel *)initWithObject:(AVObject *)object {
    SortModel *model = [[SortModel alloc]init];
    
    model.sortId = object.objectId;
    
    NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
    
    model.sortName = [dic objectForKey:@"sortName"];
    model.productCount = [[dic objectForKey:@"productCount"]integerValue];
    
    return model;
}


@end
