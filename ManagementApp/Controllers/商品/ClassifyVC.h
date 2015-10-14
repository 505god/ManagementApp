//
//  ClassifyVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

#import "SortModel.h"

///分类

@protocol ClassifyVCDelegate;

@interface ClassifyVC : BaseVC

@property (nonatomic, assign) id<ClassifyVCDelegate>delegate;

///判断是选择分类还是查看分类
@property (nonatomic, assign) BOOL isSelectedClassify;

//已经选择的分类
@property (nonatomic, strong) SortModel *selectedSortModel;

///已选择的分类--只能单选
@property (nonatomic, strong) NSMutableArray *hasSelectedClassify;

@end

@protocol ClassifyVCDelegate <NSObject>

-(void)classifyVC:(ClassifyVC *)classifyVC selectedClassify:(NSArray *)classifyArray;

@end
