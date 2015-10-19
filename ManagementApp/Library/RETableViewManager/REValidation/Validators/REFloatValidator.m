//
//  REFloatValidator.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/19.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "REFloatValidator.h"
#import "REValidation.h"

@implementation REFloatValidator

+ (NSString *)name
{
    return @"price";
}

+ (NSError *)validateObject:(NSString *)object variableName:(NSString *)name parameters:(NSDictionary *)parameters
{
    NSString *string = object ? object : @"";
    if (string.length == 0)
        return nil;
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+(.[0-9]{1,2})?$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!match)
        return [NSError re_validationErrorForDomain:@"com.REValidation.price", name];
    
    return nil;
}


@end
