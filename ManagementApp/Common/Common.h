//
//  Common.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

//我的订单-------订单类型
typedef enum{
    WQOrderTypeAll = 0,     //全部
    WQOrderTypeDeal = 1,    //交易单
    WQOrderTypeNoPay = 2,   //未付款
    WQOrderTypeNoUse=3,     //未使用
    WQOrderTypeRefund=4,     //退款
    WQOrderTypeFinish=6,     //已完成
}WQOrderType;

//语言-------系统当前语言
typedef enum{
    WQLanguageChinese = 0,   //汉语
    WQLanguageEnglish = 1,   //英语
    WQLanguageItalian = 2,   //意大利语
}WQLanguageType;

//货币-------
typedef enum{
    WQCoinCNY = 0,           //人民币
    WQCoinUSD = 1,        //美元
    WQCoinEUR = 2,          //欧元
}WQCoinType;


typedef NS_ENUM(NSInteger, MessageType) {
    WQMessageTypeText     = 0 , // 文字
    WQMessageTypePicture  = 1 , // 图片
    WQMessageTypeVoice    = 2   // 语音
};


typedef NS_ENUM(NSInteger, MessageFrom) {
    WQMessageFromMe    = 0,   // 自己发的
    WQMessageFromOther = 1    // 别人发得
};

//推送类型
typedef enum{
    WQPushTypeLogIn = 0,                //异地登陆
    WQPushTypeOrderRemindPay = 1,       //订单提醒付款
    WQPushTypeOrderRemindDelivery = 2,  //订单提醒发货
    WQPushTypeOrderDelivery = 3,        //订单发货
    WQPushTypeOrderFinish = 4,          //订单已完成
    WQPushTypeCustomer = 5,             //客户
    WQPushTypeProduct = 6,              //商品
    WQPushTypeChat = 7,                 //聊天
    WQPushTypeNone = 8
}WQPushType;

#import "PopView.h"
#import "NSObject+Motis.h"
#import "UIView+Common.h"
#import "MBProgressHUD.h"
#import "XMPPManager.h"
#import "APIClient.h"
#import "LocalDB.h"
#import "DataShare.h"
#import "Utility.h"
#import "MJRefresh.h"

///登录接口
static NSString *loginInterface = @"user";


