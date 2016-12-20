//
//  AddMemberVC.h
//  ManagementApp
//
//  Created by 邱成西 on 2016/11/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"

typedef void(^memberVCBlock)(BOOL success);
@interface AddMemberVC : BaseVC

@property (nonatomic, copy) memberVCBlock completedBlock;
@end
