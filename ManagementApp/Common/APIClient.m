//
//  APIClient.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "APIClient.h"

@implementation APIClient

//http://192.168.100.77:8080/v1/
+ (instancetype)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        
//        _sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
//        _sharedClient.securityPolicy.allowInvalidCertificates = YES;
    });
    
    return _sharedClient;
}

+ (void)cancelConnection {
    [[APIClient sharedClient].operationQueue cancelAllOperations];
}


@end
