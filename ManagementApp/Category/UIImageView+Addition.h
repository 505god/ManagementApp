//
//  UIImageView+Addition.h
//  PhotoLookTest
//
//  Created by waco on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImageView (UIImageViewEx)

- (void)addDetailShow;

- (void)gay_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
@end
