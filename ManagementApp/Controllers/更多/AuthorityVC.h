//
//  AuthorityVC.h
//  ManagementApp
//
//  Created by 邱成西 on 16/11/11.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"

typedef void(^AuthorityVCBlock)(BOOL success);

@interface AuthorityVC : BaseVC

@property (nonatomic, copy) AuthorityVCBlock completedBlock;


@end
