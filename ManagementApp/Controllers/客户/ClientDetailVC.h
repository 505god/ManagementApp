//
//  ClientDetailVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

#import "ClientModel.h"

@interface ClientDetailVC : BaseVC<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) ClientModel *clientModel;

@property (nonatomic, assign) NSInteger index;

@end
