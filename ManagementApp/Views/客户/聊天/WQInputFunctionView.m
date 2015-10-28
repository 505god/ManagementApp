//
//  WQInputFunctionView.m
//  App
//
//  Created by 邱成西 on 15/4/29.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQInputFunctionView.h"
#import "NSString+JSMessagesView.h"
#import "JKImagePickerController.h"

#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width
#define X(v)                    (v).frame.origin.x
#define Y(v)                    (v).frame.origin.y
#define WIDTH(v)                (v).frame.size.width
#define HEIGHT(v)               (v).frame.size.height
#define RECT_CHANGE_width(v,w)      CGRectMake(X(v), Y(v), w, HEIGHT(v))

@interface WQInputFunctionView ()

@end

@implementation WQInputFunctionView

-(void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    
    //图片
    self.btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSendMessage.frame = CGRectMake(Main_Screen_Width-40, 7, 30, 30);
    [self.btnSendMessage setBackgroundImage:[UIImage imageNamed:@"Chat_take_picture"] forState:UIControlStateNormal];
    [self.btnSendMessage addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnSendMessage];
    
    //输入框
    self.TextViewInput = [[WQMessageTextView alloc]initWithFrame:CGRectZero];
    self.TextViewInput.frame = CGRectMake(10, 4, Main_Screen_Width-45-10, [WQInputFunctionView textViewLineHeight]);
    self.TextViewInput.placeHolder = NSLocalizedString(@"NewMessage", @"");
    self.TextViewInput.backgroundColor = [UIColor clearColor];
    self.TextViewInput.layer.cornerRadius = 6.0f;
    self.TextViewInput.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    self.TextViewInput.layer.borderWidth = 0.65f;
    [self addSubview:self.TextViewInput];
}

- (instancetype)initWithFrame:(CGRect)frame
                      superVC:(UIViewController *)superVC
                     delegate:(id<UITextViewDelegate, WQDismissiveTextViewDelegate>)delegate
         panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
        
        self.superVC = superVC;
        self.TextViewInput.delegate = delegate;
        self.TextViewInput.keyboardDelegate = delegate;
        self.TextViewInput.dismissivePanGestureRecognizer = panGestureRecognizer;
    }
    return self;
}

#pragma mark - 录音touch事件

//发送消息（文字图片）
- (void)sendMessage:(UIButton *)sender {
    [self.TextViewInput resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.superVC.view animated:YES];
    
    __block JKImagePickerController *imagePicker = [[JKImagePickerController alloc] init];
    imagePicker.allowsMultipleSelection = NO;
    imagePicker.minimumNumberOfSelection = 1;
    imagePicker.maximumNumberOfSelection = 1;
    
    __weak typeof(self) weakSelf = self;
    imagePicker.selectAssets = ^(JKImagePickerController *imagePicker,NSArray *assets){
        JKAssets *asset = (JKAssets *)assets[0];
        
        __block UIImage *image = nil;
        ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                UIImage *tempImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                image = [Utility dealImageData:tempImg];//图片处理
                SafeRelease(tempImg);
            }
        } failureBlock:^(NSError *error) {
            [PopView showWithImageName:@"error" message:SetTitle(@"PhotoSelectedError")];
            [MBProgressHUD hideAllHUDsForView:weakSelf.superVC.view animated:YES];
        }];
        
        [imagePicker dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                [weakSelf.delegate WQInputFunctionView:weakSelf sendPicture:image];
            });
            
            [MBProgressHUD hideAllHUDsForView:weakSelf.superVC.view animated:YES];
        }];
        
    };
    imagePicker.cancelAssets = ^(JKImagePickerController *imagePicker){
        [MBProgressHUD hideAllHUDsForView:weakSelf.superVC.view animated:YES];
        [imagePicker dismissViewControllerAnimated:YES completion:^{
        }];
    };
    
    [self.superVC presentViewController:imagePicker animated:YES completion:^{
        SafeRelease(imagePicker);
    }];
}


#pragma mark - TextViewDelegate
-(void)dealloc{
    
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.TextViewInput.frame;
    
    
    NSInteger numLines = MAX([self.TextViewInput numberOfLinesOfText],
                       [self.TextViewInput.text js_numberOfLines]);

    
    self.TextViewInput.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    self.TextViewInput.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    self.TextViewInput.scrollEnabled = (numLines >= 3);
    
    if(numLines >= 6) {
        CGFloat y = self.TextViewInput.contentSize.height - self.TextViewInput.bounds.size.height;
        if (y<0) {
            y=6;
        }
        CGPoint bottomOffset = CGPointMake(0.0f, y);
        [self.TextViewInput setContentOffset:bottomOffset animated:YES];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return 3.0f;
}

+ (CGFloat)maxHeight
{
    return ([WQInputFunctionView maxLines] + 1.0f) * [WQInputFunctionView textViewLineHeight];
}

@end
