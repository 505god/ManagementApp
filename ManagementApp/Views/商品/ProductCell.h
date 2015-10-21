//
//  ProductCell.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/21.
//  Copyright © 2015年 suda_505. All rights reserved.
//



#import "ProductModel.h"

typedef enum CellState:NSUInteger{
    CellStateUnexpanded=0,
    CellStateExpanded=1,
} TableViewCellState;

@interface ProductCell : UITableViewCell

@property (nonatomic,assign) TableViewCellState state;///当前的状态
@property (nonatomic,assign) UITableView* tableView;

@property (nonatomic, copy) void (^hotChange)(ProductModel *productMode,NSIndexPath *idxPath);

@property (nonatomic, copy) void (^saleChange)(ProductModel *productMode,NSIndexPath *idxPath);

@property (nonatomic, copy) void (^deleteCell)(NSIndexPath *idxPath);


@property (nonatomic, strong) ProductModel *productModel;

@property (nonatomic, strong) NSIndexPath *idxPath;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(NSInteger)type inTableView:(UITableView *)tableView;
@end
