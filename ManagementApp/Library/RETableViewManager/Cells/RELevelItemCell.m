//
//  RELevelItemCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/22.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "RELevelItemCell.h"
#import "RETableViewManager.h"

#define Button_tag 1000

@interface RELevelItemCell ()

@property (assign, readwrite, nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) UIButton *aBtn;
@property (nonatomic, strong) UIButton *bBtn;
@property (nonatomic, strong) UIButton *cBtn;
@property (nonatomic, strong) UIButton *dBtn;
@end



@implementation RELevelItemCell
@synthesize item = _item;

+ (BOOL)canFocusWithItem:(RETableViewItem *)item
{
    return YES;
}

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    if (_item != nil) {
        [_item removeObserver:self forKeyPath:@"currentIndex"];
    }
}

-(UIButton *)returnBtnWithImage:(NSString *)imageString tag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = Button_tag+tag;
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn setImage:[Utility getImgWithImageName:[NSString stringWithFormat:@"%@@2x",imageString]] forState:UIControlStateNormal];
    [btn setImage:[Utility getImgWithImageName:[NSString stringWithFormat:@"%@_sele@2x",imageString]] forState:UIControlStateSelected];
    return btn;
}

-(void)buttonPressed:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    self.item.currentIndex = btn.tag-Button_tag;
    
    if (self.item.onChange) {
        self.item.onChange(self.item);
    }
}

- (void)cellDidLoad
{
    [super cellDidLoad];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.aBtn = [self returnBtnWithImage:@"charc_1_28" tag:0];
    self.bBtn = [self returnBtnWithImage:@"charc_2_28" tag:1];
    self.cBtn = [self returnBtnWithImage:@"charc_3_28" tag:2];
    self.dBtn = [self returnBtnWithImage:@"charc_4_28" tag:3];
    
    [self.contentView addSubview:self.aBtn];
    [self.contentView addSubview:self.bBtn];
    [self.contentView addSubview:self.cBtn];
    [self.contentView addSubview:self.dBtn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
    }
}

- (void)cellWillAppear
{
    [super cellWillAppear];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.text = self.item.title.length == 0 ? @" " : self.item.title;
    
    self.currentIndex = self.item.currentIndex;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    
    [self.textLabel sizeToFit];
    self.textLabel.frame = (CGRect){frame.origin.x,frame.origin.y,self.textLabel.width,frame.size.height};
    
    self.aBtn.frame = (CGRect){self.textLabel.right+40,(self.height-30)/2,30,30};
    self.bBtn.frame = (CGRect){self.aBtn.right+20,(self.height-30)/2,30,30};
    self.cBtn.frame = (CGRect){self.bBtn.right+20,(self.height-30)/2,30,30};
    self.dBtn.frame = (CGRect){self.cBtn.right+20,(self.height-30)/2,30,30};
    
    if ([self.tableViewManager.delegate respondsToSelector:@selector(tableView:willLayoutCellSubviews:forRowAtIndexPath:)])
        [self.tableViewManager.delegate tableView:self.tableViewManager.tableView willLayoutCellSubviews:self forRowAtIndexPath:[self.tableViewManager.tableView indexPathForCell:self]];
}

#pragma mark -
#pragma mark Handle state

- (void)setItem:(RELevelItem *)item
{
    if (_item != nil) {
        [_item removeObserver:self forKeyPath:@"currentIndex"];
    }
    
    _item = item;
    
    [_item addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    for (int i=0; i<4; i++) {
        UIButton *btn = (UIButton *)[self.contentView viewWithTag:(Button_tag+i)];
        [btn setSelected:NO];
        
        if (i==currentIndex) {
            [btn setSelected:YES];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentIndex"]){
        NSInteger color = [[change objectForKey: NSKeyValueChangeNewKey]integerValue];
        self.currentIndex = color;
    }
}
@end
