//
//  ClientTypeVC.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "BaseVC.h"

///客户类型

#import "RETableViewManager.h"

@interface ClientTypeVC : BaseVC<RETableViewManagerDelegate>

@property (weak, readwrite, nonatomic) RETableViewItem *item;
@property (strong, readwrite, nonatomic) NSArray *options;
@property (strong, readonly, nonatomic) RETableViewManager *tableViewManager;
@property (strong, readonly, nonatomic) RETableViewSection *mainSection;
@property (assign, readwrite, nonatomic) BOOL multipleChoice;
@property (copy, readwrite, nonatomic) void (^completionHandler)(RETableViewItem *item);
@property (strong, readwrite, nonatomic) RETableViewCellStyle *style;
@property (weak, readwrite, nonatomic) id<RETableViewManagerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil item:(RETableViewItem *)item options:(NSArray *)options multipleChoice:(BOOL)multipleChoice completionHandler:(void(^)(RETableViewItem *item))completionHandler;

@end
