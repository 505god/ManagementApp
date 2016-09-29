//
//  MaterialModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "MaterialModel.h"

@implementation MaterialModel

+(MaterialModel *)initWithObject:(AVObject *)object {
    MaterialModel *model = [[MaterialModel alloc]init];
    
    model.materialId = object.objectId;
    model.materialName = [object objectForKey:@"materialName"];
    model.productCount = [[object objectForKey:@"productCount"]integerValue];
    
    return model;
}

@end
