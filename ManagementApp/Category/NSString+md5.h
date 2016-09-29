//
//  NSString+md5.h
//  ManagementApp
//
//  Created by 邱成西 on 15/12/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (md5)

-(NSString *)getPlateForm;

-(NSString *) md5HexDigest;

- (NSString *) md5;
@end
