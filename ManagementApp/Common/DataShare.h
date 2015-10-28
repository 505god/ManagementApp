//
//  DataShare.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///单例

#import "UserModel.h"

typedef void(^CompleteBlock)(NSArray *array);

@interface DataShare : NSObject{
    CompleteBlock completeBlock;
}

@property (nonatomic, strong) UserModel *userModel;

///xmpp注册
@property (nonatomic, assign) BOOL idRegister;//1＝注册，0=未注册

@property (nonatomic, assign) BOOL isInMessageView;
///当前聊天对象的JID
@property (nonatomic, strong) NSString *otherJID;

///聊天输入框获取键盘语言
@property (nonatomic, strong) NSString *getLanguage;

@property (nonatomic, strong) NSMutableArray *messageArray;

//判断是否是点击推送进来的
@property (nonatomic, assign) BOOL isPushing;
@property (nonatomic, assign) WQPushType pushType;

+ (DataShare *)sharedService;

///颜色
@property (nonatomic, strong) NSMutableArray *colorArray;
-(void)sortColors:(NSArray *)colors CompleteBlock:(CompleteBlock)complet;

///分类
@property (nonatomic, strong) NSMutableArray *classifyArray;
-(void)sortClassify:(NSArray *)classify CompleteBlock:(CompleteBlock)complet;

///材质
@property (nonatomic, strong) NSMutableArray *materialArray;
-(void)sortMaterial:(NSArray *)material CompleteBlock:(CompleteBlock)complet;
@end
