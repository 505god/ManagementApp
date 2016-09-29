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

@property (nonatomic, weak) IBOutlet UITableView *sortTable;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *typeArray;

///数据源判断  0=商品分类  1=客户等级分类
@property (nonatomic, assign) NSInteger currentPage;
///商品：segment分热卖和下架；客户等级：segment分私密客户和供货商
@property (nonatomic, weak) IBOutlet UIImageView * leftIconImgV;
@property (nonatomic, weak) IBOutlet UIImageView *rightIconImgV;
@property (nonatomic, weak) IBOutlet UILabel *leftNameLab;
@property (nonatomic, weak) IBOutlet UILabel *rightNameLab;

-(IBAction)leftBtnPressed:(id)sender;
-(IBAction)rightBtnPressed:(id)sender;


@end
