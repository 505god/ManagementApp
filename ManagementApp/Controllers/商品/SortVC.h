//
//  SortVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

///分类

#import "ICSDrawerController.h"

@interface SortVC : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property(nonatomic, weak) ICSDrawerController *drawer;


@end
