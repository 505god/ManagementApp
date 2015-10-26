//
//  ClientVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

///客户

#import "MainVC.h"

@interface ClientVC : BaseVC

@property (nonatomic, weak) MainVC *mainVC;

///区分  0=ABCD  1=私密客户  2=供货商
@property (nonatomic, assign) NSInteger type;
@end
