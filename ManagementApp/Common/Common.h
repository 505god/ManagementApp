//
//  Common.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//



//推送类型
typedef NS_ENUM(NSInteger, WQPushType) {
    WQPushTypeNone = 0,
    WQPushTypeClient = 1,      //新用户
    WQPushTypeOrder = 2       //订单
};

typedef enum OrderFilterType:NSUInteger{
    OrderFilterType_date=0,//时间
    OrderFilterType_status=1,//状态
    OrderFilterType_mark=2//标签
} OrderFilterType;

typedef enum DateFilterType:NSUInteger{
    DateFilterType_today=0,//今天
    DateFilterType_yesterday=1,//昨天
    DateFilterType_week=2,//本周
    DateFilterType_month=3,//本月
    DateFilterType_latest=4,//最近3个月
    DateFilterType_select=5//选择日期
} DateFilterType;

typedef enum StatusFilterType:NSUInteger{
    StatusFilterType_pay_none=0,//未付款
    StatusFilterType_pay_part=1,//部分付款
    StatusFilterType_pay_all=2,//全部付款
    StatusFilterType_deliver_none=3,//未发货
    StatusFilterType_deliver_part=4,//部分发货
    StatusFilterType_deliver_all=5//全部发货
} StatusFilterType;

#import "PopView.h"
#import "NSObject+Motis.h"
#import "UIView+Common.h"
#import "MBProgressHUD.h"
#import "LeanChatManager.h"
#import "DataShare.h"
#import "Utility.h"
#import "MJRefresh.h"
#import "JSONKit.h"
#import "NSDate+Utils.h"
#import <AVOSCloud/AVOSCloud.h>

