//
//  REProductItem.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/18.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "REProductItem.h"

@implementation REProductItem

+ (instancetype)itemWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder image:(UIImage *)image imageString:(NSString *)imageString{
    return [[self alloc] initWithTitle:title value:value placeholder:placeholder image:image imageString:imageString];
}
- (id)initWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder image:(UIImage *)image imageString:(NSString *)imageString{
    self = [super init];
    if (!self)
        return nil;
    
    self.title = title;
    self.value = value;
    self.placeholder = placeholder;
    self.picImg = image;
    self.imageString = imageString;
    
    return self;
}

#pragma mark -
#pragma mark Error validation

- (NSArray *)errors
{
    return [REValidation validateObject:self.value name:self.name ? self.name : self.title validators:self.validators];
}
@end
