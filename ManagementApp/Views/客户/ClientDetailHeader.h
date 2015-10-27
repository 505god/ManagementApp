//
//  ClientDetailHeader.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ClientModel.h"

@interface ClientDetailHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) ClientModel *clientModel;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void (^segmentChange)(NSInteger index);

@property (nonatomic, copy) void (^showPrivate)(ClientModel *clientModel);

+(CGFloat)returnHeightWithIndex:(NSInteger)index;
@end
