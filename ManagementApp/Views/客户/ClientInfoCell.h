//
//  ClientInfoCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ClientModel.h"

@interface ClientInfoCell : UITableViewCell

@property (nonatomic, strong) ClientModel *clientModel;

@property (nonatomic, strong) NSIndexPath *idxPath;

@end
