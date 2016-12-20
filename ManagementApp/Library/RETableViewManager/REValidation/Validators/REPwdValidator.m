//
//  REPwdValidator.m
//  ManagementApp
//
//  Created by 邱成西 on 16/10/26.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "REPwdValidator.h"
#import "NSError+REValidation.h"

@implementation REPwdValidator

+ (NSString *)name
{
    return @"pwd";
}

+ (NSError *)validateObject:(NSString *)object variableName:(NSString *)name parameters:(NSDictionary *)parameters
{
    NSString *string = object ? object : @"";
    if (string.length == 0)
        return nil;
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    
    if (!match)
        return [NSError re_validationErrorForDomain:@"com.REValidation.email", name];
    
    return nil;
}

@end
