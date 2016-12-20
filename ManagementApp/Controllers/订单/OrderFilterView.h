//
//  OrderFilterView.h
//  ManagementApp
//
//  Created by 邱成西 on 15/11/3.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OrderFilterViewBlock)(NSInteger orderType,NSInteger type,NSString *time,BOOL finished);

@interface OrderFilterView : UIControl

@property (nonatomic, weak) IBOutlet UIView *customView;
@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, strong) OrderFilterViewBlock completedBlock;

- (id)initWithFrame:(CGRect)frame orderType:(NSInteger)orderType type:(NSInteger)type filterArray:(NSMutableArray *)filterArray;
@end
