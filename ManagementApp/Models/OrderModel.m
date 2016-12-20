//
//  OrderModel.m
//  ManagementApp
//
//  Created by 王志 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderModel.h"

#import "OrderStockModel.h"

#import "NSDate+Utils.h"

@implementation OrderModel

+ (NSDictionary*)mts_mapping {
    return  @{@"orderCode": mts_key(orderCode),
              @"payType": mts_key(payType),
              @"orderPrice": mts_key(orderPrice),
              @"orderMark": mts_key(orderMark),
              @"discountType": mts_key(discountType),
              @"discount": mts_key(discount),
              @"clientName": mts_key(clientName),
              @"clientId": mts_key(clientId),
              @"itemCount": mts_key(itemCount),
              @"orderCount": mts_key(orderCount),
              @"status": mts_key(orderStatus),
              @"isPay": mts_key(isPay),
              @"arrearsPrice": mts_key(arrearsPrice),
              @"isDeliver": mts_key(isDeliver),
              @"tax": mts_key(tax),
              @"taxNum": mts_key(taxNum),
              @"profit": mts_key(profit),
              @"ered": mts_key(ered),
              @"cred": mts_key(cred)
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}


+(OrderModel *)initWithObject:(AVObject *)object {
    OrderModel *model = [[OrderModel alloc]init];
    
    AVObject *object4 = [object objectForKey:@"client"];
    if (object4 != nil) {
        NSDictionary *dic2 =(NSDictionary *)[object4 objectForKey:@"localData"];
        ClientModel *model2 = [[ClientModel alloc]init];
        [model2 mts_setValuesForKeysWithDictionary:dic2];
        model2.clientId = object4.objectId;
        model.clientModel = model2;
    }
    
    NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
    [model mts_setValuesForKeysWithDictionary:dic];
    model.orderId = object.objectId;
    
    NSArray *products = [object objectForKey:@"products"];
    if (products != nil && products.count>0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i=0; i<products.count; i++) {
            AVObject *object6 = (AVObject *)products[i];
            NSDictionary *dicc =(NSDictionary *)[object6 objectForKey:@"localData"];
            OrderStockModel *model2 = [[OrderStockModel alloc]init];
            [model2 mts_setValuesForKeysWithDictionary:dicc];
            model2.orderStockId = object6.objectId;
            
            [tempArray addObject:model2];
        }
        model.productArray = tempArray;
    }
    
    model.timeString = [object.createdAt stringLoacalDateWithFormat:@"dd/MM HH:mm"];
    
    model.timeStr = [object.createdAt stringLoacalDateWithFormat:@"dd/MM"];
    
    return model;
}

-(NSMutableArray *)productArray {
    if (!_productArray) {
        _productArray = [[NSMutableArray alloc]init];
    }
    return _productArray;
}
@end
