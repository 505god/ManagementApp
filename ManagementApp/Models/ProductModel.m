//
//  ProductModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductModel.h"

@implementation ProductModel

-(NSMutableArray *)productStockArray {
    if (!_productStockArray) {
        _productStockArray = [[NSMutableArray alloc]init];
    }
    return _productStockArray;
}


+(ProductModel *)initWithObject:(AVObject *)object {
    
    ProductModel *model = [[ProductModel alloc]init];
    
    AVFile *attachment = [object objectForKey:@"header"];
    if (attachment != nil) {
        model.picHeader = attachment.url;
    }
    
    AVObject *object4 = [object objectForKey:@"sort"];
    if (object4 != nil) {
        SortModel *model2 = [SortModel initWithObject:object4];
        model.sortModel = model2;
        model.sortId = model2.sortId;
    }
    
    AVObject *object5 = [object objectForKey:@"material"];
    if (object5 != nil) {
        MaterialModel *model2 = [MaterialModel initWithObject:object5];
        model.materialModel = model2;
        model.materialId = model2.materialId;
    }
    
    NSArray *products = [object objectForKey:@"products"];
    if (products != nil && products.count>0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i=0; i<products.count; i++) {
            AVObject *object6 = (AVObject *)products[i];
            
            NSDictionary *dic =(NSDictionary *)[object6 objectForKey:@"localData"];
            ProductStockModel *model2 = [[ProductStockModel alloc]init];
            [model2 mts_setValuesForKeysWithDictionary:dic];
            model2.ProductStockId = object6.objectId;
            model2.stockNum = model2.num-model2.saleANum-model2.saleBNum-model2.saleCNum-model2.saleDNum;
            
            AVFile *attachment = [object6 objectForKey:@"header"];
            if (attachment != nil) {
                model2.picHeader = attachment.url;
            }
            
            AVObject *object15 = [object6 objectForKey:@"color"];
            if (object15 != nil) {
                [object15 fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                    ColorModel *model12 = [ColorModel initWithObject:object];
                    model12.isExit = YES;
                    model2.colorModel = model12;
                }];
            }
            model2.isExit = YES;
            [tempArray addObject:model2];
        }
        model.productStockArray = tempArray;
    }
    
    
    model.productId = object.objectId;
    NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
    
    
    model.discountType = [dic[@"discountType"] integerValue];
    model.discount = [dic[@"discount"] floatValue];
    model.aPrice = [dic[@"a"] floatValue];
    model.bPrice = [dic[@"b"] floatValue];
    model.cPrice = [dic[@"c"] floatValue];
    model.dPrice = [dic[@"d"] floatValue];
    model.selected = [dic[@"selected"] integerValue];
    model.productDetails = dic[@"details"];
    model.isSetting = [dic[@"isSetting"] boolValue];
    model.totalNum = [dic[@"totalNum"] integerValue];
    model.singleNum = [dic[@"singleNum"] integerValue];
    
    model.productCode = [dic objectForKey:@"productCode"];
    model.purchaseprice = [[dic objectForKey:@"purchasePrice"]floatValue];
    model.packageNum = [[dic objectForKey:@"packingNumber"]integerValue];
    model.productName = [dic objectForKey:@"productName"];
    model.isDisplay = [[dic objectForKey:@"sale"]boolValue];
    model.isHot = [[dic objectForKey:@"hot"]boolValue];
    model.stockCount = [[dic objectForKey:@"stockNum"]integerValue];
    model.saleCount = [[dic objectForKey:@"saleNum"]integerValue];
    model.productMark = [dic objectForKey:@"remark"];
    model.profitStatus = [[dic objectForKey:@"profitStatus"]integerValue];
    model.profit = [[dic objectForKey:@"profit"]floatValue];
    
    model.isWarning = [[dic objectForKey:@"isWarning"]boolValue];
    return model;
}
@end
