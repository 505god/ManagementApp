//
//  TabBarItem.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RKNotificationHub.h"

@interface TabBarItem : UIControl

@property (assign,nonatomic) BOOL isSelected;

@property (nonatomic, strong) UIImageView *logoImg;
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) RKNotificationHub *notificationHub;

- (id)initWithFrame:(CGRect)frame normal:(NSString *)normal active:(NSString *)active title:(NSString *)title;
@end
