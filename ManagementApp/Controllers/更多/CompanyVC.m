//
//  CompanyVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/13.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "CompanyVC.h"
#import "JKImagePickerController.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Utils.h"
#import "RETableViewManager.h"
#import "TapImg.h"
#import "PwdVC.h"

@interface CompanyVC ()<RETableViewManagerDelegate,TapImgDelegate>
@property (nonatomic, strong) TapImg *headerImg;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation CompanyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    [self setTableViewUI];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tappedWithObject:(id) sender {
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    JKImagePickerController *imagePicker = [[JKImagePickerController alloc] init];
    imagePicker.allowsMultipleSelection = NO;
    imagePicker.minimumNumberOfSelection = 1;
    imagePicker.maximumNumberOfSelection = 1;
    
    imagePicker.selectAssets = ^(JKImagePickerController *imagePicker,NSArray *assets){
        JKAssets *asset = (JKAssets *)assets[0];
        
        __block UIImage *image = nil;
        ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                UIImage *tempImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                image = [Utility dealImageData:tempImg];//图片处理
                weakSelf.headerImg.image = image;
            }
        } failureBlock:^(NSError *error) {
            [PopView showWithImageName:@"error" message:SetTitle(@"PhotoSelectedError")];
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        }];
        
        [imagePicker dismissViewControllerAnimated:YES completion:^{
            AVFile *attachment = [weakSelf.currentUser objectForKey:@"header"];
            if (attachment != nil) {
                [attachment deleteInBackground];
            }
            
            NSData *imageData = UIImagePNGRepresentation(weakSelf.headerImg.image);
            AVFile *imageFile = [AVFile fileWithName:@"image.png" data:imageData];
            
            [weakSelf.currentUser setObject:imageFile forKey:@"header"];
            [weakSelf.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [weakSelf.currentUser refresh];
                if ([weakSelf.currentUser.objectId isEqualToString:MainId]) {
                    [AVUser changeCurrentUser:weakSelf.currentUser save:YES];
                }
            }];
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        }];
        
    };
    imagePicker.cancelAssets = ^(JKImagePickerController *imagePicker){
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [imagePicker dismissViewControllerAnimated:YES completion:^{
        }];
    };
    
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:^{
    }];
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"Company") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
}

-(UIView *)headerViewUI {
    CGFloat height = 150;
    
    UIView *view = [[UIView alloc]initWithFrame:(CGRect){0,0,[UIScreen mainScreen].bounds.size.width,height}];
    
    self.headerImg = [[TapImg alloc]initWithFrame:(CGRect){([UIScreen mainScreen].bounds.size.width-120)/2,(height-120)/2,120,120}];
    self.headerImg.delegate = self;
    self.headerImg.layer.cornerRadius = 8;
    self.headerImg.layer.masksToBounds = YES;
    
    self.headerImg.image = [Utility getImgWithImageName:@"assets_placeholder_picture@2x"];
    AVFile *attachment = [self.currentUser objectForKey:@"header"];
    if (attachment != nil) {
        NSString *url = [attachment getThumbnailURLWithScaleToFit:true width:120 height:120];
        [self.headerImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    }
    
    [view addSubview:self.headerImg];
    
    return view;
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    
    
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    _manager.delegate = self;
    
    __weak __typeof(self)weakSelf = self;
    //------------------------------------------------------------------
    RETableViewSection *section1 = [RETableViewSection section];
    section1.footerHeight = 10;
    section1.headerView = [self headerViewUI];
    [_manager addSection:section1];

    //名字
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"Company_info") value:self.currentUser.username placeholder:SetTitle(@"product_required")];
    nameItem.onEndEditing = ^(RETextItem *item){
        if (![item.value isEqualToString:weakSelf.currentUser.username]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                weakSelf.currentUser.username = item.value;
                [weakSelf.currentUser saveEventually];
                
                [weakSelf.currentUser refresh];
                
                if ([weakSelf.currentUser.objectId isEqualToString:MainId]) {
                    [AVUser changeCurrentUser:weakSelf.currentUser save:YES];
                }
            });
        }
    };
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.validators = @[@"presence"];
    [section1 addItem:nameItem];
    
    //电话
    RETextItem *phoneItem = [RETextItem itemWithTitle:SetTitle(@"phone") value:self.currentUser.mobilePhoneNumber placeholder:SetTitle(@"product_required")];
    phoneItem.enabled = NO;
    phoneItem.alignment = NSTextAlignmentRight;
    phoneItem.validators = @[@"presence"];
    [section1 addItem:phoneItem];
    
    //邮箱
    RETextItem *emailItem = [RETextItem itemWithTitle:SetTitle(@"email") value:self.currentUser.email placeholder:SetTitle(@"product_set")];
    
    emailItem.onEndEditing = ^(RETextItem *item){
        if (![item.value isEqualToString:weakSelf.currentUser.email]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                weakSelf.currentUser.email = item.value;
                [weakSelf.currentUser saveEventually];
                
                [weakSelf.currentUser refresh];
                
                if ([weakSelf.currentUser.objectId isEqualToString:MainId]) {
                    [AVUser changeCurrentUser:weakSelf.currentUser save:YES];
                }
            });
        }
    };
    emailItem.keyboardType = UIKeyboardTypeEmailAddress;
    emailItem.alignment = NSTextAlignmentRight;
    emailItem.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [section1 addItem:emailItem];
    
    //------------------------------------------------------------------
    RETableViewSection *section2 = [RETableViewSection section];
    section2.footerHeight = 10;
    [_manager addSection:section2];
    //税

    CGFloat tax = [[self.currentUser objectForKey:@"tax"] floatValue];
    RETextItem *taxItem = [RETextItem itemWithTitle:SetTitle(@"company_tax") value:tax==0?@"":[NSString stringWithFormat:@"%@",[self.currentUser objectForKey:@"tax"]] placeholder:SetTitle(@"company_taxinfo")];
    taxItem.alignment = NSTextAlignmentRight;
    taxItem.keyboardType = UIKeyboardTypeDecimalPad;
    taxItem.onEndEditing = ^(RETextItem *item){
        if (([item.value floatValue]-tax)!=0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf.currentUser setObject:[NSNumber numberWithFloat:[item.value floatValue]] forKey:@"tax"];
                [weakSelf.currentUser saveEventually];
                
                [weakSelf.currentUser refresh];
                
                if ([weakSelf.currentUser.objectId isEqualToString:MainId]) {
                    [AVUser changeCurrentUser:weakSelf.currentUser save:YES];
                }
            });
        }
    };
    [section2 addItem:taxItem];
    
    //------------------------------------------------------------------
    if (![self.currentUser.objectId isEqualToString:MainId]) {
        RETableViewSection *section3 = [RETableViewSection section];
        section3.footerHeight = 10;
        [_manager addSection:section3];
        
        NSInteger dayNum = [[self.currentUser objectForKey:@"day"] integerValue];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self.currentUser.createdAt toDate:[NSDate date] options:0];
        
        NSInteger day = [components day];
        //使用时间
        RERadioItem *tiemItem = [RERadioItem itemWithTitle:SetTitle(@"Company_time") value:[NSString stringWithFormat:@"%ld%@",dayNum-day,SetTitle(@"Company_day")] selectionHandler:^(RERadioItem *item) {
            [item deselectRowAnimated:YES];
            
        }];
        tiemItem.accessoryType = UITableViewCellAccessoryNone;
        [section3 addItem:tiemItem];
    }
    
    //------------------------------------------------------------------
    RETableViewSection *section13 = [RETableViewSection section];
    [self.manager addSection:section13];
    
    RERadioItem *pwdItem = [RERadioItem itemWithTitle:SetTitle(@"editPwd") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        PwdVC *vc = LOADVC(@"PwdVC");
        [weakSelf.navigationController pushViewController:vc animated:YES];
        vc = nil;
    }];
    [section13 addItem:pwdItem];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 150;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark - keyboard

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         self.tableView.frame = frame;
                         self.keyboardHeight = keyboardRect.size.height;
                     }];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         self.tableView.frame = frame;
                         self.keyboardHeight = 0;
                     }];
}

@end
