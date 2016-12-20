//
//  XLTextField.m
//  MailSuffix
//
//  Created by XL10014 on 16/7/8.
//  Copyright © 2016年 XL10014. All rights reserved.
//
#define RGBA(r,g,b,a)   [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

#import "XLTextField.h"

/**
 *  textField布局类型
 */
typedef NS_ENUM( NSUInteger,XLLayoutType) {
    XLLayoutTypeAuto, // 自动布局
    XLLayoutTypeHand //手动布局
};

@interface XLTextField()<UITextFieldDelegate>

@property (nonatomic, copy)     UILabel * mailLabel;
@property (nonatomic, strong)   NSString * email;                   //完整的邮箱

@end

@implementation XLTextField

- (void)awakeFromNib
{
    [self configInitializeMessage:XLLayoutTypeAuto];
}

- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize
{
    if (self== [super init]) {
        self.frame = frame;
        self.font = [UIFont systemFontOfSize:fontSize];
        [self configInitializeMessage:XLLayoutTypeHand];
    }
    return self;
}

/**
 *  匹配邮箱过程
 *
 *  @param range  range
 *  @param string 用户输入string
 */
- (void)configMailMatchingRange:(NSRange)range replacementString:(NSString *)string
{
    //获取完整的输入文本
    NSString *completeStr = [self.text stringByReplacingCharactersInRange:range withString:string];
    //以@符号分割文本
    NSArray *temailArray = [completeStr componentsSeparatedByString:@"@"];
    //获取邮箱前缀
    NSString *emailString = [temailArray firstObject];
    
    //邮箱匹配 没有输入@符号时 用@匹配
    NSString *matchString = @"@";
    if(temailArray.count > 1){
        //如果已经输入@符号 截取@符号以后的字符串作为匹配字符串
        matchString = [completeStr substringFromIndex:emailString.length];
    }
    //匹配邮箱 得到所有跟当前输入匹配的邮箱后缀
    NSMutableArray *suffixArray = [self checkEmailStr:matchString];
    
    //边界控制 如果没有跟当前输入匹配的后缀置为@""
    NSString *fixStr = suffixArray.count > 0 ? [suffixArray firstObject] : @"";
    //将lblEmail部分字段隐藏
    NSInteger cutLenth = suffixArray.count > 0 ? completeStr.length : emailString.length;
    
    //最终的邮箱地址
    self.email = fixStr.length > 0 ? [NSString stringWithFormat:@"%@%@",emailString,fixStr] : completeStr;
    
    //设置lblEmail 的attribute
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",emailString,fixStr]];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0,cutLenth)];
    self.mailLabel.attributedText = attributeString;
    
    //清空文本框内容时 隐藏lblEmail
    if(completeStr.length == 0){
        self.mailLabel.text = @"";
        self.email = @"";
    }
}

/**
 *  结束输入操作
 */
- (void)didEndEditing
{
    self.text = self.email;
    self.mailLabel.text = @"";
}

/**
 *  替换邮箱匹配类型
 *
 *  @param string 匹配的字段
 *
 *  @return 匹配成功的Array
 */
- (NSMutableArray *)checkEmailStr:(NSString *)string{
    NSMutableArray *filterArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString *str in self.mailTypeArray) {
        if([str hasPrefix:string]){
            [filterArray addObject:str];
        }
    }
    return filterArray;
}

/**
 *  初始化信息
 */
- (void)configInitializeMessage:(XLLayoutType)layoutType
{
    self.delegate = self;
    _email = [[ NSMutableString alloc]initWithCapacity:0];
    _mailLabel = [[UILabel alloc] init];
    [_mailLabel setTextColor:RGBA(170, 170, 170, 1)];
    [_mailLabel setFont:self.font];
    
    if (layoutType == XLLayoutTypeAuto)
    {
        [self addSubview:_mailLabel];
        _mailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint  * leftConstant = [NSLayoutConstraint constraintWithItem:_mailLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:6];
        NSLayoutConstraint  * rightConstant = [NSLayoutConstraint constraintWithItem:_mailLabel
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1
                                                                            constant:0];
        NSLayoutConstraint  * topConstant = [NSLayoutConstraint constraintWithItem:_mailLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:0];
        NSLayoutConstraint  * bottomConstant = [NSLayoutConstraint constraintWithItem:_mailLabel
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1
                                                                             constant:-1];
        [self addConstraint:leftConstant];
        [self addConstraint:rightConstant];
        [self addConstraint:topConstant];
        [self addConstraint:bottomConstant];
        
    } else if (layoutType == XLLayoutTypeHand)
    {
        _mailLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 2);
        [self addSubview:_mailLabel];
    }
}

- (void)setMailMatchColor:(UIColor *)mailMatchColor
{
    _mailMatchColor = mailMatchColor;
    [_mailLabel setTextColor:mailMatchColor];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(XLTextFieldShouldBeginEditing:)]) {
        [self.customDelegate XLTextFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(XLTextFieldDidBeginEditing:)]) {
        [self.customDelegate XLTextFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self didEndEditing];
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(XLTextFieldDidEndEditing:)]) {
        [self.customDelegate XLTextFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [self configMailMatchingRange:range replacementString:string];
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(XLTextField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.customDelegate XLTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.text = self.email;
    self.mailLabel.text = @"";
    if (self.didPressedReturnCompletion) {
        self.didPressedReturnCompletion(self);
    }
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(XLTextFieldShouldReturn:)]) {
        [self.customDelegate XLTextFieldShouldReturn:textField];
    }
    return YES;
}
@end
