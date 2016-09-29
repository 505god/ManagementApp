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

@end
