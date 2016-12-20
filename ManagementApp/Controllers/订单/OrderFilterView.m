//
//  OrderFilterView.m
//  ManagementApp
//
//  Created by 邱成西 on 15/11/3.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderFilterView.h"

#import "RFSegmentView.h"
#import "RETableViewManager.h"


@interface OrderFilterView ()<RFSegmentViewDelegate>

@property (nonatomic, assign) NSInteger orderType;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSMutableArray *filterArray;

@property (nonatomic, strong) RFSegmentView* segmentView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;
@property (nonatomic, strong) RETableViewSection *section;

@property (nonatomic, strong) NSMutableArray *itemArray;


@property (nonatomic, weak) IBOutlet UIButton *sureBtn;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) double timeInstance;

@property (nonatomic, strong) RETextItem *dateItem;
@end

@implementation OrderFilterView

-(void)dealloc {
//    [self removeObserver:self forKeyPath:@"orderType"];
}

- (id)initWithFrame:(CGRect)frame orderType:(NSInteger)orderType type:(NSInteger)type filterArray:(NSMutableArray *)filterArray{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"OrderFilterView" owner:self options:nil];
        if(arrayOfViews.count < 1){return nil;}
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[OrderFilterView class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        self.clipsToBounds = YES;
        
        self.frame = frame;
        
        self.orderType = orderType;
        self.type = type;
        self.filterArray = filterArray;
        
        self.datePicker.maximumDate = [NSDate date];
        
        [self addTarget:self action:@selector(hidden:) forControlEvents:UIControlEventTouchUpInside];
        ///检测orderType的变化
//        [self addObserver:self forKeyPath:@"orderType" options:0 context:nil];
        
        [self.sureBtn setTitle:SetTitle(@"sureBtn") forState:UIControlStateNormal];
        
        [self setSegmentControl];
    }
    return self;
}

-(void)setSegmentControl {
    self.segmentView = [[RFSegmentView alloc] initWithFrame:CGRectZero items:@[SetTitle(@"date"),SetTitle(@"status")]];
    self.segmentView.tintColor       = COLOR(80, 80, 80, 1);
    self.segmentView.delegate        = self;
    self.segmentView.selectedIndex   = self.orderType;
    
    [self.segmentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.segmentView];
    
    // `view` 的左边距离 `self.view` 的左边 10 点.
    NSLayoutConstraint *viewLeft = [NSLayoutConstraint constraintWithItem:self.segmentView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1
                                                                 constant:15];
    
    // `view` 的右边距离 `self.view` 的右边 10 点.
    NSLayoutConstraint *viewRight = [NSLayoutConstraint constraintWithItem:self.segmentView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:-15];
    // `view` 的顶部距离 `self.view` 的顶部 10 点.
    NSLayoutConstraint *viewTop = [NSLayoutConstraint constraintWithItem:self.segmentView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:5];
    // `view` 的高度是 40 点.
    NSLayoutConstraint *viewHeight = [NSLayoutConstraint constraintWithItem:self.segmentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:40];
    // 把约束添加到父视图上.
    [self addConstraints:@[viewLeft,viewRight,viewTop,viewHeight]];
    
    [self setTableViewUI];
}

-(void)setTableViewUI {
    // Create manager
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    
    // Add a section
    self.section = [RETableViewSection section];
    [self.manager addSection:self.section];
    
    NSArray * filterNameArray = @[@[SetTitle(@"Today"),SetTitle(@"Yesterday"),SetTitle(@"week"),SetTitle(@"month"),SetTitle(@"latest_month"),SetTitle(@"select_date")],@[SetTitle(@"pay_none"),SetTitle(@"pay_part"),SetTitle(@"pay_all"),SetTitle(@"deliver_none"),SetTitle(@"deliver_part"),SetTitle(@"deliver_all")]];
    
    __weak __typeof(self)weakSelf = self;
    ///----------------------------------------------------------
    NSMutableArray *dataArray1 = [NSMutableArray array];
    NSMutableArray *dataArray2 = [NSMutableArray array];
    NSMutableArray *dataArray3 = [NSMutableArray array];
    for (int i=0; i<6; i++) {
        if (i==5) {
            self.dateItem = [RETextItem itemWithTitle:filterNameArray[0][i] value:self.time?self.time:@"" placeholder:@""];
            self.dateItem.enabled = NO;
            self.dateItem.alignment = NSTextAlignmentRight;
            self.dateItem.cellHeight = 40;
            self.dateItem.selectionType = 1;
            self.dateItem.selectionHandler = ^(RETextItem *item) {
                [item deselectRowAnimated:YES];
                item.value = [[NSDate date] stringLoacalDateWithFormat:@"MM/dd/yyyy"];
                weakSelf.time = item.value;
                [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
                
                weakSelf.type = item.indexPath.row;
                weakSelf.customView.hidden = NO;
                weakSelf.isShow = YES;
            };
            [dataArray1 addObject:self.dateItem];
        }else {
            RETextItem *item1 = [self returnItemWithTitle:filterNameArray[0][i] value:@"" image:nil];
            [dataArray1 addObject:item1];
        }
    }
    
    for (int i=0; i<6; i++) {
        RETextItem *item1 = [self returnItemWithTitle:filterNameArray[1][i] value:@"" image:nil];
        item1.textAlignment = NSTextAlignmentRight;
        [dataArray2 addObject:item1];
    }
    
    for (int i=0; i<6; i++) {
        RETextItem *item1 = [self returnItemWithTitle:@"    " value:self.filterArray.count>0?self.filterArray[2][i]:@"0" image:[NSString stringWithFormat:@"tag_0%d_58@2x",(i+1)]];
        [dataArray3 addObject:item1];
    }
    
    [self.itemArray addObject:dataArray1];
    [self.itemArray addObject:dataArray2];
    [self.itemArray addObject:dataArray3];
    
    
    [self.section addItemsFromArray:self.itemArray[self.orderType]];
}

-(RETextItem *)returnItemWithTitle:(NSString *)title value:(NSString *)value image:(NSString *)image{
    __weak __typeof(self)weakSelf = self;
    RETextItem *item1 = [RETextItem itemWithTitle:title value:value placeholder:@""];
    if (image.length>0) {
        item1.image = [Utility getImgWithImageName:image];
    }
    
    item1.enabled = NO;
    item1.cellHeight = 40;
    item1.selectionType = 1;
    item1.alignment = NSTextAlignmentRight;
    item1.selectionHandler = ^(RETextItem *item) {
        [item deselectRowAnimated:YES];
        weakSelf.type = item.indexPath.row;
        if (weakSelf.completedBlock) {
            weakSelf.completedBlock(weakSelf.orderType,weakSelf.type,0,YES);
        }
    };
    
    return item1;
}

#pragma mark - getter/setter

-(NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [[NSMutableArray alloc]init];
    }
    return _itemArray;
}

#pragma mark - segmentView代理

- (void)segmentViewDidSelected:(NSUInteger)index {
    self.orderType = index;
    
    if (self.orderType!=0) {
        self.isShow = NO;
        self.customView.hidden = YES;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"orderType"]) {
        [self.section replaceItemsWithItemsFromArray:self.itemArray[self.orderType]];
        [self.section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

#pragma mark -
#pragma mark Date picker value

- (IBAction)datePickerValueDidChange:(UIDatePicker *)datePicker {
    
    self.time = [datePicker.date stringLoacalDateWithFormat:@"MM/dd/yyyy"];
    self.dateItem.value = self.time;
    [self.dateItem reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
}

-(IBAction)sureBtnPressed:(id)sender {
    if (self.completedBlock) {
        self.completedBlock(self.orderType,self.type,self.time,YES);
    }
}

-(void)hidden:(id)sender {
    self.completedBlock(self.orderType,self.type,self.time,NO);
}
-(void)layoutSubviews {
    [super layoutSubviews];
    
    
}
@end
