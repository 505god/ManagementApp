//
//  REProductItemCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/18.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "REProductItemCell.h"
#import "RETableViewManager.h"
#import "UIImageView+WebCache.h"

@protocol TapImgDelegate;

@interface TapImg : UIImageView

@property (nonatomic, assign) id<TapImgDelegate> delegate;

@end

@protocol TapImgDelegate <NSObject>

- (void)tappedWithObject:(id) sender;
@end

@implementation TapImg

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
        [self addGestureRecognizer:tap];
        SafeRelease(tap);
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) Tapped:(UIGestureRecognizer *) gesture
{
    if ([self.delegate respondsToSelector:@selector(tappedWithObject:)])
    {
        [self.delegate tappedWithObject:self];
    }
}


@end


@interface REProductItemCell ()<TapImgDelegate>

@property (nonatomic, strong) TapImg *deleteImg;

@property (nonatomic, strong) TapImg *pictureImg;

@property (nonatomic, strong) UIImageView *addImg;
@property (nonatomic, strong) UIImageView *backImg;

@property (nonatomic, strong) UILabel *stockLab;

@property (assign, readwrite, nonatomic) BOOL enabled;

@end

@implementation REProductItemCell

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
    
    self.deleteImg = [[TapImg alloc]initWithFrame:(CGRect){0,0,20.5,20.5}];
    self.deleteImg.image = [Utility getImgWithImageName:@"delete_icon_7_0@2x"];
    self.deleteImg.delegate = self;
    self.deleteImg.tag = 100;
    [self.contentView addSubview:self.deleteImg];
    
    self.pictureImg = [[TapImg alloc]initWithFrame:(CGRect){0,0,75,75}];
    self.pictureImg.delegate = self;
    self.pictureImg.tag = 200;
    self.pictureImg.image = [Utility getImgWithImageName:@"camera_item_detail@2x"];
    self.pictureImg.contentMode = UIViewContentModeScaleAspectFill;
    self.pictureImg.clipsToBounds = YES;
    [self.contentView addSubview:self.pictureImg];
    
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
    
    self.textLabel.textColor = [UIColor lightGrayColor];
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textAlignment = NSTextAlignmentRight;
    self.textLabel.text = self.item.title.length == 0 ? @" " : self.item.title;
    self.textLabel.hidden = NO;
    self.textField.text = self.item.value;
    self.textField.placeholder = self.item.placeholder;
    self.textField.font = [UIFont systemFontOfSize:17];
//    self.textField.backgroundColor = [UIColor redColor];
    self.stockLab.font = [UIFont systemFontOfSize:17];
    self.textField.textAlignment = NSTextAlignmentRight;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.stockLab.text = self.textField.text.length==0?@"0":self.textField.text;
    self.stockLab.textAlignment = NSTextAlignmentRight;
    
    if (self.item.imageString != nil) {
        [self.pictureImg sd_setImageWithURL:[NSURL URLWithString:self.item.imageString]];
    }else {
        if (self.item.picImg != nil) {
            self.pictureImg.image = self.item.picImg;
        }
    }
    
    self.enabled = self.item.enabled;
}

- (UIResponder *)responder
{
    return self.textField;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.deleteImg.frame = (CGRect){15,(self.height-20.5)/2,20.5,20.5};
    self.pictureImg.frame = (CGRect){self.deleteImg.right+10,(self.height-75)/2,75,75};
    
    
    self.textLabel.frame = (CGRect){self.width-20-150,self.pictureImg.top+5,150,20};
    
    CGFloat width = 59;
    self.textField.frame = (CGRect){self.width-20-width,self.pictureImg.bottom-40,width,40};
    self.stockLab.frame = self.textField.frame;
    
    self.backImg.frame = (CGRect){self.width-15-91,self.pictureImg.bottom-40,91,41};
    self.addImg.frame = (CGRect){self.backImg.left+5,self.backImg.top+(41-12)/2,12,12};
    
    if ([self.tableViewManager.delegate respondsToSelector:@selector(tableView:willLayoutCellSubviews:forRowAtIndexPath:)])
        [self.tableViewManager.delegate tableView:self.tableViewManager.tableView willLayoutCellSubviews:self forRowAtIndexPath:[self.tableViewManager.tableView indexPathForCell:self]];
}

#pragma mark -
#pragma mark TapImgDelegate

- (void)tappedWithObject:(id) sender {
    TapImg *imgView = (TapImg *)sender;
    if (imgView.tag==100) {
        if (self.item.deleteHandler)
            self.item.deleteHandler(self.item);
    }else if (imgView.tag==200){
        if (self.item.selectedPictureHandler)
            self.item.selectedPictureHandler(self.item);
    }
}

#pragma mark -
#pragma mark Handle state

- (void)setItem:(REProductItem *)item
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
