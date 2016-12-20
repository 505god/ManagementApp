//
//  Utility.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "Utility.h"
#import "NSString+md5.h"

static UIImageView *orginImageView;

@implementation Utility

#pragma mark - 判断字符串是否为空

+(BOOL)checkString:(NSString *)string {
    if (string.length==0) {
        return NO;
    }
    if (string == nil || string == NULL) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return NO;
    }
    return YES;
}

#pragma mark - 判断接口

+(void)interfaceWithStatus:(NSInteger)status msg:(NSString *)msg {
    if (status==0) {
        
    }else if (status==101 || status==100) {
    }
    [PopView showWithImageName:@"error" message:msg];
}

#pragma mark - 获取本地图片

+(UIImage *)getImgWithImageName:(NSString *)imgName{
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:@".png"]];
}

#pragma mark - 隐藏UITableView多余的分割线

+ (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark -  对图片data大小比例压缩

+(UIImage *)dealImageData:(UIImage *)image {
    
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return [UIImage imageWithData:imageData];
}

#pragma mark -  正则判断

+(BOOL)predicateText:(NSString *)text regex:(NSString *)regex {
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![test evaluateWithObject:text]){
        return NO;
    }else {
        return YES;
    }
}

#pragma mark - 显示大图

+(void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    orginImageView = avatarImageView;
    orginImageView.alpha = 0;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    CGRect oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.7];
    backgroundView.alpha=1;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=[orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
        backgroundView.alpha=0;
    }];
}

#pragma mark - 返回document文件夹的路径

+(NSString *)returnPath {
    NSString *path;
    if (Platform>5.0) {
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }else{
        path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return path;
}

#pragma mark - 邀请码

+(NSString *)getPlateForm {
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    CFRelease(uuidRef);
    
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    
    return [uniqueId getPlateForm];
}

#pragma mark - 清除数据

+(void)dataShareClear {
    [DataShare sharedService].classifyArray = nil;
    [DataShare sharedService].colorArray = nil;
    [DataShare sharedService].materialArray = nil;
    [LCChatKitExample invokeThisMethodBeforeLogoutSuccess:^{
    } failed:^(NSError *error) {
    }];
    
//    AVInstallation *installation = [AVInstallation currentInstallation];
//    [installation setObject:@"" forKey:@"cid"];
//    [installation saveInBackground];
}

#pragma mark - 返回销售类型 saleA,saleB..
+(NSString *)returnSale:(ClientModel *)model {
    if (model.clientLevel==0) {
        return @"saleA";
    }else if (model.clientLevel==1) {
        return @"saleB";
    }else if (model.clientLevel==2) {
        return @"saleC";
    }else if (model.clientLevel==3) {
        return @"saleD";
    }
    return @"saleA";
}

#pragma mark - 返回价格类型 a,b..
+(NSString *)returnPrice:(ClientModel *)model {
    if (model.clientLevel==0) {
        return @"a";
    }else if (model.clientLevel==1) {
        return @"b";
    }else if (model.clientLevel==2) {
        return @"c";
    }else if (model.clientLevel==3) {
        return @"d";
    }
    return @"a";
}


+ (BOOL)isAuthority {
   
    if ([DataShare sharedService].userObject.type==1) {
        return true;
    }
    
    if ([DataShare sharedService].userObject.isExpire) {
        [PopView showWithImageName:nil message:SetTitle(@"authority_error")];
        return false;
    }
    
    return  true;
}
@end
