//
//  LocalDataBase.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 数据库
 * 功能－－创建并保存数据库，创建表
 */

#import "FMDatabase.h"

@interface LocalDataBase : NSObject

@property (nonatomic, strong) FMDatabase *db;


@end
