//
//  NSString+md5.m
//  ManagementApp
//
//  Created by 邱成西 on 15/12/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+md5.h"

@implementation NSString (md5)

-(NSString *)getPlateForm {
    
    NSString *u = [self md5HexDigest];
    
    NSString *retult = [u substringWithRange:NSMakeRange(0, 6)];
    
    return retult;
}

-(NSString *) md5HexDigest {
    const char *original_str = [self UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        
        [hash appendFormat:@"%02X", result[i]];
    
    return [hash uppercaseString];
}

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

@end
