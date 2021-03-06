//
//  DataShare.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///单例

#import <AVOSCloud/AVOSCloud.h>

#import "UserModel.h"
#import "ClientModel.h"
typedef void(^CompleteBlock)(NSArray *array);

@interface DataShare : NSObject{
    CompleteBlock completeBlock;
}
@property (nonatomic, strong) AppDelegate *appDel;

//当前登录的对象
@property (nonatomic, strong) UserModel *userObject;
//当前聊天的对象
@property (nonatomic, strong) ClientModel *clientObject;
@property (nonatomic, strong) UserModel *chatUser;

@property (nonatomic, strong) NSMutableDictionary *unreadMessageDic;

//判断是否是点击推送进来的
@property (nonatomic, assign) BOOL isPushing;
@property (nonatomic, assign) WQPushType pushType;
@property (nonatomic, strong) NSString *pushText;
+ (DataShare *)sharedService;

@property (nonatomic, assign) NSInteger escape;
///颜色
@property (nonatomic, strong) NSMutableArray *colorArray;
-(void)sortColors:(NSArray *)colors CompleteBlock:(CompleteBlock)complet;

///分类
@property (nonatomic, strong) NSMutableArray *classifyArray;
-(void)sortClassify:(NSArray *)classify CompleteBlock:(CompleteBlock)complet;

///材质
@property (nonatomic, strong) NSMutableArray *materialArray;
-(void)sortMaterial:(NSArray *)material CompleteBlock:(CompleteBlock)complet;

//代理
@property (nonatomic, strong) NSMutableArray *agentArray;
-(void)sortAgent:(NSArray *)agent CompleteBlock:(CompleteBlock)complet;
@end
