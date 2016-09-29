//
//  AgentDetailVC.h
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"
#import "UserModel.h"


@interface AgentDetailVC : BaseVC

@property (nonatomic, strong) UserModel *model;

@property(strong, nonatomic) NSIndexPath *idxPath;
@property(copy, nonatomic) void (^updateHandler)(NSIndexPath *idxPath,UserModel *model);
@end
