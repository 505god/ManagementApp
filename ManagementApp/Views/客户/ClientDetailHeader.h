//
//  ClientDetailHeader.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ClientModel.h"
#import "RKNotificationHub.h"
@interface ClientDetailHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) ClientModel *clientModel;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void (^segmentChange)(NSInteger index);

@property (nonatomic, copy) void (^showPrivate)(ClientModel *clientModel);

@property (nonatomic, copy) void (^sendMessage)(ClientModel *clientModel);

@property (nonatomic, strong) RKNotificationHub *notificationHub;

+(CGFloat)returnHeightWithIndex:(NSInteger)index;
@end
