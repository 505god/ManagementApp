//
//  UserModel.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/25.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSString *userHead;
@end
