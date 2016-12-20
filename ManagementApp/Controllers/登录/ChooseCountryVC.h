//
//  ChooseCountryVC.h
//  ManagementApp
//
//  Created by 邱成西 on 16/10/24.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "BaseVC.h"

@class SMSSDKCountryAndAreaCode;

@protocol ChooseCountryVCDelegate;

@interface ChooseCountryVC : BaseVC

@property (nonatomic, strong)  UITableView *table;

@property (nonatomic, strong) NSDictionary *allNames;
@property (nonatomic, strong) NSMutableDictionary *names;
@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) id <ChooseCountryVCDelegate> delegate;
@end

@protocol ChooseCountryVCDelegate <NSObject>
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data;
@end
