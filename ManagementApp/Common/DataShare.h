//
//  DataShare.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <Foundation/Foundation.h>

///单例

typedef void(^CompleteBlock)(NSArray *array);

@interface DataShare : NSObject{
    CompleteBlock completeBlock;
}

+ (DataShare *)sharedService;

///颜色
@property (nonatomic, strong) NSMutableArray *colorArray;
-(void)sortColors:(NSArray *)colors CompleteBlock:(CompleteBlock)complet;

///分类
@property (nonatomic, strong) NSMutableArray *classifyArray;
-(void)sortClassify:(NSArray *)classify CompleteBlock:(CompleteBlock)complet;


@end
