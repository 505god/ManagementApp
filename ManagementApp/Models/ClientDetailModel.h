//
//  ClientDetailModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientDetailModel : NSObject

@property (nonatomic, assign) NSInteger clientDetailId;

@property (nonatomic, strong) NSString *clientDetailCode;

@property (nonatomic, assign) CGFloat totalPrice;

@property (nonatomic, assign) NSInteger totalNum;

@property (nonatomic, strong) NSString *time;
@end
