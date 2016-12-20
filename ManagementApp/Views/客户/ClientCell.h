//
//  ClientCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/24.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ClientModel.h"
#import "RKNotificationHub.h"

@interface ClientCell : UITableViewCell

@property (nonatomic, strong) ClientModel *clientModel;

@property (nonatomic, strong) RKNotificationHub *notificationHub;

//2=交易次数最多 3=交易金额最高 4=欠款最多
@property (nonatomic, assign) NSInteger type;
@end
