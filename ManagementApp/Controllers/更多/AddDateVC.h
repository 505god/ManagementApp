//
//  AddDateVC.h
//  ManagementApp
//
//  Created by 邱成西 on 2016/11/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"

typedef void(^dateVCBlock)(BOOL success);

@interface AddDateVC : BaseVC

@property (nonatomic, strong) UserModel *model;

@property (nonatomic, copy) dateVCBlock completedBlock;
@end
