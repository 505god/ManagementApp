//
//  XLTextField.h
//  MailSuffix
//
//  Created by XL10014 on 16/7/8.
//  Copyright © 2016年 XL10014. All rights reserved.
//

/* 用法指南
 * textField可通过两种方式创建 auaulayout or frame
 * 第一种在xib中创建，textField样式可在xib自行设置，匹配的邮箱区域颜色可自行设置
 * 第二种通过手动frame创建 两个基本参数设置大小和字号，其他设置可额外自行设置
 */

#import <UIKit/UIKit.h>

/**
 *  如果接入的类需要在textField的代理方法中做操作 可实现对应的协议即可
 */
@protocol XLEmailTextFieldDelegate <NSObject>

@optional

- (BOOL)XLTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)XLTextFieldDidBeginEditing:(UITextField *)textField;
- (void)XLTextFieldDidEndEditing:(UITextField *)textField;
- (BOOL)XLTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)XLTextFieldShouldReturn:(UITextField *)textField;

@end

typedef void(^didPressedReturn)(UITextField *);

@interface XLTextField : UITextField

- (instancetype)init __attribute__((unavailable("init方法不可用，请用initWithName:fontSzie:")));
+ (instancetype)new  __attribute__((unavailable("new方法不可用，请用initWithName:fontSzie:")));

/**
 *  optional  根据自己需求
 */
@property (nonatomic, weak) id<XLEmailTextFieldDelegate> customDelegate;

/**
 *  Optional 点击return的回调block 根据自己需求
 */
@property (nonatomic, copy) didPressedReturn didPressedReturnCompletion;


/**
 *  Optional  匹配的邮箱类型后缀默认是RGB为170 170 170的颜色，可自行设置
 */
@property (nonatomic, strong) UIColor * mailMatchColor;


/**
 *
 *  1.通过xib创建只需要赋值此参数 即可
 *  @param mailTypeArray 邮箱匹配类型
 *
 */
@property (nonatomic, strong) NSMutableArray *mailTypeArray;


/**
 *  2.通过手写创建textField时候调用
 *
 *  @param frame    frame大小
 *  @param fontSize textField大小
 *
 *  @return self
 */
- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize;


@end
