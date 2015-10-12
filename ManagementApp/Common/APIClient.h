//
//  APIClient.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "AFHTTPSessionManager.h"

/*
 基于NSURLConnection
 基于NSURLSession  用于iOS 7 / Mac OS X 10.9及以上版本。
 */
///接口


@interface APIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

+ (void)cancelConnection;

@end
