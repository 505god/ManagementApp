//
//  WQMessageTextView.m
//  App
//
//  Created by 邱成西 on 15/5/2.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQMessageTextView.h"

#import "NSString+JSMessagesView.h"

@interface WQMessageTextView ()

- (void)setup;

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification;


@end

@implementation WQMessageTextView
- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    _placeHolderTextColor = [UIColor lightGrayColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeySend;
    self.textAlignment = NSTextAlignmentLeft;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    _placeHolder = nil;
    _placeHolderTextColor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextInputCurrentInputModeDidChangeNotification
                                                  object:self];
}

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder
{
    if([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    NSUInteger maxChars = [WQMessageTextView maxCharactersPerLine];
    if([placeHolder length] > maxChars) {
        placeHolder = [placeHolder substringToIndex:maxChars - 8];
        placeHolder = [[placeHolder js_stringByTrimingWhitespace] stringByAppendingFormat:@"..."];
    }
    
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor
{
    if([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - Message text view

- (NSUInteger)numberOfLinesOfText
{
    return [WQMessageTextView numberOfLinesForMessage:self.text];
}

+ (NSUInteger)maxCharactersPerLine
{
    return 33;
}

+ (NSUInteger)numberOfLinesForMessage:(NSString *)text{

    if ([[DataShare sharedService].getLanguage isEqualToString:@"zh-Hans"] || [[DataShare sharedService].getLanguage isEqualToString:@"zh-Hant"]) {
        return (text.length*2 / [WQMessageTextView maxCharactersPerLine]) + 1;
    }
    return (text.length / [WQMessageTextView maxCharactersPerLine]) + 1;
}

-(void) keyboardChangeMode:(NSNotification *)notification {
    UITextInputMode *currentInputMode = self.textInputMode;
    [DataShare sharedService].getLanguage = currentInputMode.primaryLanguage;

}


#pragma mark - Text view overrides

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)insertText:(NSString *)text
{
    [super insertText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.placeHolder) {
        CGRect placeHolderRect = CGRectMake(10.0f,
                                            7.0f,
                                            rect.size.width,
                                            rect.size.height);
        
        [self.placeHolderTextColor set];
        
        [self.placeHolder drawInRect:placeHolderRect
                            withFont:self.font
                       lineBreakMode:NSLineBreakByTruncatingTail
                           alignment:self.textAlignment];
    }
}

#pragma mark - Notifications

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

@end
