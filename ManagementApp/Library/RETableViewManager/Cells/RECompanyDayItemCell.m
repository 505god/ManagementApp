//
//  RECompanyDayItemCell.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "RECompanyDayItemCell.h"
#import "RETableViewManager.h"

@interface RECompanyDayItemCell ()

@property (nonatomic, strong) UIImageView *addImg;
@property (nonatomic, strong) UIImageView *backImg;

@property (assign, readwrite, nonatomic) BOOL enabled;
@property (nonatomic, strong) UILabel *stockLab;

@end

@implementation RECompanyDayItemCell

@synthesize item = _item;

+ (BOOL)canFocusWithItem:(RETableViewItem *)item
{
    return YES;
}
#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    if (_item != nil) {
        [_item removeObserver:self forKeyPath:@"enabled"];
    }
}

- (void)cellDidLoad
{
    [super cellDidLoad];
    
    self.stockLab = [[UILabel alloc]initWithFrame:CGRectZero];
    self.stockLab.hidden = YES;
    [self.contentView insertSubview:self.stockLab aboveSubview:self.textField];
    
    self.backImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.backImg.image = [Utility getImgWithImageName:@"stock_bg@2x"];
    [self.contentView insertSubview:self.backImg belowSubview:self.textField];
    
    self.addImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.addImg.hidden  = YES;
    self.addImg.image = [Utility getImgWithImageName:@"add_highlighted@2x"];
    [self.contentView insertSubview:self.addImg belowSubview:self.textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.textField becomeFirstResponder];
    }
}

- (void)cellWillAppear
{
    [super cellWillAppear];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textAlignment = NSTextAlignmentRight;
    self.textLabel.text = self.item.title.length == 0 ? @" " : self.item.title;
    self.textLabel.hidden = NO;
    self.textField.text = self.item.value;
    self.textField.placeholder = self.item.placeholder;
    self.textField.font = [UIFont systemFontOfSize:16];
    //    self.textField.backgroundColor = [UIColor redColor];
    self.stockLab.font = [UIFont systemFontOfSize:16];
    self.textField.textAlignment = NSTextAlignmentRight;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.stockLab.text = self.textField.text.length==0?@"0":self.textField.text;
    self.stockLab.textAlignment = NSTextAlignmentRight;
    
    self.enabled = self.item.enabled;
}

- (UIResponder *)responder
{
    return self.textField;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    self.textLabel.frame = (CGRect){15,(self.height-self.textLabel.height)/2,self.textLabel.width,self.textLabel.height};
    
    CGFloat width = 59;
    self.textField.frame = (CGRect){self.width-20-width,(self.height-40)/2,width,40};
    self.stockLab.frame = self.textField.frame;
    
    self.backImg.frame = (CGRect){self.width-15-91,(self.height-41)/2,91,41};
    self.addImg.frame = (CGRect){self.backImg.left+5,self.backImg.top+(41-12)/2,12,12};
    
    if ([self.tableViewManager.delegate respondsToSelector:@selector(tableView:willLayoutCellSubviews:forRowAtIndexPath:)])
        [self.tableViewManager.delegate tableView:self.tableViewManager.tableView willLayoutCellSubviews:self forRowAtIndexPath:[self.tableViewManager.tableView indexPathForCell:self]];
}



#pragma mark -
#pragma mark Handle state

- (void)setItem:(RECompanyDayItem *)item
{
    if (_item != nil) {
        [_item removeObserver:self forKeyPath:@"enabled"];
    }
    
    _item = item;
    
    [_item addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    self.userInteractionEnabled = _enabled;
    
    self.textLabel.enabled = _enabled;
    self.textField.enabled = _enabled;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[REBoolItem class]] && [keyPath isEqualToString:@"enabled"]) {
        BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
        
        self.enabled = newValue;
    }
}

#pragma mark -
#pragma mark Text field events

- (void)textFieldDidChange:(UITextField *)textField
{
    self.item.value = textField.text;
    if (self.item.onChange)
        self.item.onChange(self.item);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.stockLab.hidden = NO;
    self.stockLab.text = textField.text.length==0?@"0":textField.text;
    textField.text = @"";
    [UIView animateWithDuration:0.25f animations:^{
        self.stockLab.frame = (CGRect){self.stockLab.left-100,self.stockLab.top,self.stockLab.width,self.stockLab.height};
    }completion:^(BOOL finished) {
        self.addImg.hidden = NO;
    }];
    
    
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (indexPath) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = self.item.returnKeyType;
    }
    [self updateActionBarNavigationControl];
    [self.parentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowIndex inSection:self.sectionIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    if (self.item.onBeginEditing)
        self.item.onBeginEditing(self.item);
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f animations:^{
        self.stockLab.frame = (CGRect){self.stockLab.left+100,self.stockLab.top,self.stockLab.width,self.stockLab.height};
    }completion:^(BOOL finished) {
        self.stockLab.hidden = YES;
        self.addImg.hidden = YES;
        textField.text = [NSString stringWithFormat:@"%ld",[self.stockLab.text integerValue]+[textField.text integerValue]];
        
        self.item.value = textField.text;
        
        if (self.item.onEndEditing)
            self.item.onEndEditing(self.item);
    }];
    
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.item.onReturn)
        self.item.onReturn(self.item);
    if (self.item.onEndEditing)
        self.item.onEndEditing(self.item);
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (!indexPath) {
        [self endEditing:YES];
        return YES;
    }
    RETableViewCell *cell = (RETableViewCell *)[self.parentTableView cellForRowAtIndexPath:indexPath];
    [cell.responder becomeFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    if (self.item.charactersLimit) {
        NSUInteger newLength = textField.text.length + string.length - range.length;
        shouldChange = newLength <= self.item.charactersLimit;
    }
    
    if (self.item.onChangeCharacterInRange && shouldChange)
        shouldChange = self.item.onChangeCharacterInRange(self.item, range, string);
    
    return shouldChange;
}


@end
