//
//  TapImg.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/29.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapImgDelegate;

@interface TapImg : UIImageView

@property (nonatomic, assign) id<TapImgDelegate> delegate;

@end

@protocol TapImgDelegate <NSObject>

- (void)tappedWithObject:(id) sender;
@end
