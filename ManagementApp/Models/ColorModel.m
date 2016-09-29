//
//  ColorModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ColorModel.h"

@implementation ColorModel

+(ColorModel *)initWithObject:(AVObject *)object {
    ColorModel *model = [[ColorModel alloc]init];
    
    model.colorId = object.objectId;
    
    NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
    
    model.colorName = [dic objectForKey:@"colorName"];
    model.productCount = [[dic objectForKey:@"productCount"]integerValue];
    
    return model;
}
@end
