//
//  MaterialVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

//材质

#import "MaterialModel.h"

@protocol MaterialVCDelegate;

@interface MaterialVC : BaseVC

@property (nonatomic, assign) id<MaterialVCDelegate>delegate;

///判断是选择分类还是查看分类
@property (nonatomic, assign) BOOL isSelectedClassify;

//已经选择的分类
@property (nonatomic, strong) MaterialModel *selectedMaterialModel;

///已选择的分类--只能单选
@property (nonatomic, strong) NSMutableArray *hasSelectedMaterial;

@end

@protocol MaterialVCDelegate <NSObject>

-(void)materialVC:(MaterialVC *)materialVC selectedMaterial:(NSArray *)materialArray;

@end
