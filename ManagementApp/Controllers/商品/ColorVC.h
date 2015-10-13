//
//  ColorVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"


///颜色列表

#import "ColorModel.h"

@protocol ColorVCDelegate;

@interface ColorVC : BaseVC

@property (nonatomic, assign) id<ColorVCDelegate>delegate;

///判断是选择颜色还是查看颜色
@property (nonatomic, assign) BOOL isSelectedColor;

///已选择的颜色
@property (nonatomic, strong) NSMutableArray *hasSelectedColor;

@end

@protocol ColorVCDelegate <NSObject>


@end