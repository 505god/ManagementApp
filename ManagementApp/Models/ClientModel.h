//
//  ClientModel.h
//  ManagementApp
//
//  Created by ydd on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientModel : NSObject

///客户等级id
@property (nonatomic, assign) NSInteger clientId;
///客户等级名称
@property (nonatomic, strong) NSString *clientName;
///各等级客户数量
@property (nonatomic, assign) NSInteger clientCount;

@end
