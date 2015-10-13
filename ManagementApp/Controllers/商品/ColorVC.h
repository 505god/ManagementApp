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

@property (nonatomic, assign) BOOL isPresentVC;

@property (nonatomic, strong) ColorModel *selectedColorObj;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

///已选择的颜色
@property (nonatomic, strong) NSMutableArray *hasSelectedColor;

@end

@protocol ColorVCDelegate <NSObject>


@end