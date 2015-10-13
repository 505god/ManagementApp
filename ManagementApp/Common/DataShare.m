//
//  DataShare.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "DataShare.h"

#import "WQIndexedCollationWithSearch.h"//检索
#import "PinYinForObjc.h"

#import "ColorModel.h"

@implementation DataShare
- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (DataShare *)sharedService {
    static dispatch_once_t once;
    static DataShare *dataService = nil;
    
    dispatch_once(&once, ^{
        dataService = [[super alloc] init];
    });
    return dataService;
}

#pragma mark - getter/setter

-(NSMutableArray *)colorArray {
    if (!_colorArray) {
        _colorArray = [[NSMutableArray alloc]init];
    }
    return _colorArray;
}

#pragma mark - 检索

///A-Z，按照姓名进行排序

- (NSMutableArray *)emptyPartitionedArray {
    NSUInteger sectionCount = [[[WQIndexedCollationWithSearch currentCollation] sectionTitles] count];
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int i = 0; i < sectionCount; i++) {
        [sections addObject:[NSMutableArray array]];
    }
    return sections;
}

///对数据进行自定义，方便页面排版
///0=颜色
-(void)setupDataArray:(NSArray *)dataArray type:(NSInteger)type{
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    
    if (type==0) {
        [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *array = (NSArray *)obj;
            
            if (array.count>0) {
                NSMutableDictionary *aDic = [NSMutableDictionary dictionary];
                [aDic setObject:array forKey:@"data"];
                
                ColorModel *colorModel = (ColorModel *)array[0];
                
                NSString *nameSection = [[NSString stringWithFormat:@"%c",[[PinYinForObjc chineseConvertToPinYin:colorModel.colorName] characterAtIndex:0]]uppercaseString];
                
                NSString *nameRegex = @"^[a-zA-Z]+$";
                NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
                if ([nameTest evaluateWithObject:nameSection]) {//字母
                    [aDic setObject:nameSection forKey:@"indexTitle"];
                }else {
                    [aDic setObject:@"#" forKey:@"indexTitle"];
                }
                [mutableArray addObject:aDic];
            }
        }];
    }
    
    
    if (completeBlock) {
        completeBlock(mutableArray);
        SafeRelease(mutableArray);
    }
}

///对数据按照A－Z进行排序
-(void)sortColors:(NSArray *)colors CompleteBlock:(CompleteBlock)complet{
    completeBlock = [complet copy];
    
    NSMutableArray *mutableArray = [[self emptyPartitionedArray] mutableCopy];
    //添加分类
    for (ColorModel *colorModel in colors) {
        SEL selector = @selector(colorName);
        NSInteger index = [[WQIndexedCollationWithSearch currentCollation]
                           sectionForObject:colorModel
                           collationStringSelector:selector];
        [mutableArray[index] addObject:colorModel];
    }
    
    [self setupDataArray:mutableArray type:0];
}

@end
