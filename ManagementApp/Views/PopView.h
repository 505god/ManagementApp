//
//  PopView.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopView : UIWindow

+ (void)showWithImageName:(NSString*)imageName message:(NSString *)string;
+ (void)hiddenImage:(void (^)(BOOL finish))compleBlock;

@end
