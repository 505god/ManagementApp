//
//  CompanyVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/13.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "CompanyVC.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Utils.h"
#import "RETableViewManager.h"
#import "TapImg.h"
#import "AuthorityVC.h"
#import "PwdVC.h"

#import "MembersVC.h"

@interface CompanyVC ()<RETableViewManagerDelegate,TapImgDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) TapImg *headerImg;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (strong, nonatomic) RERadioItem *tiemItem;

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
    
    
    [self.view endEditing:YES];
    
    QWeakSelf(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self addActionTarget:alert title:SetTitle(@"photograph") color:kThemeColor action:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return ;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = weakself;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [weakself presentViewController:picker animated:YES completion:nil];
    }];
    [self addActionTarget:alert title:SetTitle(@"album") color:kThemeColor action:^(UIAlertAction *action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = weakself;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakself presentViewController:picker animated:YES completion:nil];
    }];
    [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    [self.headerImg sd_setImageWithURL:[NSURL URLWithString:[DataShare sharedService].userObject.header] placeholderImage:[Utility getImgWithImageName:@"assets_placeholder_picture@2x"]];
    
    [view addSubview:self.headerImg];
    
    return view;
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom} style:UITableViewStylePlain];
    self.tableView.scrollEnabled = NO;
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    
    
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    _manager.delegate = self;
    
    RETableViewSection *section1 = [RETableViewSection section];
    section1.footerHeight = 10;
    section1.headerView = [self headerViewUI];
    [_manager addSection:section1];
    
    //名字
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"company_name") value:[DataShare sharedService].userObject.userName placeholder:SetTitle(@"product_required")];
    nameItem.onEndEditing = ^(RETextItem *item){
        if (![item.value isEqualToString:[DataShare sharedService].userObject.userName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [DataShare sharedService].userObject.userName = item.value;
                [AVUser currentUser].username = item.value;
                [[AVUser currentUser] saveEventually];
                [[AVUser currentUser] refresh];
            });
        }
    };
    nameItem.alignment = NSTextAlignmentRight;
    nameItem.validators = @[@"presence"];
    [section1 addItem:nameItem];
    
    //电话
    RETextItem *phoneItem = [RETextItem itemWithTitle:SetTitle(@"log_phone") value:[DataShare sharedService].userObject.phone placeholder:SetTitle(@"product_set")];
    phoneItem.onChange = ^(RETextItem *item){
        if (![item.value isEqualToString:[DataShare sharedService].userObject.phone]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [DataShare sharedService].userObject.phone = item.value;
                [AVUser currentUser].mobilePhoneNumber = item.value;
                [[AVUser currentUser] saveEventually];
                [[AVUser currentUser] refresh];
            });
        }
    };
    phoneItem.keyboardType = UIKeyboardTypeNumberPad;
    phoneItem.alignment = NSTextAlignmentRight;
    [section1 addItem:phoneItem];
    
    //邮箱
    RETextItem *emailItem = [RETextItem itemWithTitle:SetTitle(@"email") value:[DataShare sharedService].userObject.email placeholder:SetTitle(@"product_set")];
    
    emailItem.onEndEditing = ^(RETextItem *item){
        if (![item.value isEqualToString:[DataShare sharedService].userObject.email]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [DataShare sharedService].userObject.email = item.value;
                [AVUser currentUser].email = item.value;
                [[AVUser currentUser] saveEventually];
                [[AVUser currentUser] refresh];
            });
        }
    };
    emailItem.validators = @[@"email"];
    emailItem.keyboardType = UIKeyboardTypeEmailAddress;
    emailItem.alignment = NSTextAlignmentRight;
    emailItem.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [section1 addItem:emailItem];
    
    //---------------------------------------------------------------
    /*
     RETableViewSection *section2 = [RETableViewSection section];
     section2.footerHeight = 10;
     [_manager addSection:section2];
    //税
    
    CGFloat tax = [DataShare sharedService].userObject.tax;
    RETextItem *taxItem = [RETextItem itemWithTitle:SetTitle(@"company_tax") value:tax==0?@"":[NSString stringWithFormat:@"%.2f",tax] placeholder:SetTitle(@"company_taxinfo")];
    taxItem.alignment = NSTextAlignmentRight;
    taxItem.keyboardType = UIKeyboardTypeDecimalPad;
    taxItem.onEndEditing = ^(RETextItem *item){
        if (([item.value floatValue]-tax)!=0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [DataShare sharedService].userObject.tax = [item.value floatValue];
                
                [AVUser currentUser][@"tax"] = @([item.value floatValue]);
                [[AVUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                    
                }];
                [[AVUser currentUser] refresh];
            });
        }
    };
    [section2 addItem:taxItem];
     */
    
    
    //---------------------------------------------------------------
    if ([DataShare sharedService].escape==1) {
        RETableViewSection *section3 = [RETableViewSection section];
        section3.footerHeight = 10;
        [_manager addSection:section3];
        
        [[AVUser currentUser] refresh];
        UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
        [DataShare sharedService].userObject = user;
        //使用时间
        self.tiemItem = [RERadioItem itemWithTitle:SetTitle(@"Company_time") value:[NSString stringWithFormat:SetTitle(@"Company_day"),(long)[DataShare sharedService].userObject.dayNumber,(long)[DataShare sharedService].userObject.hourNumber,(long)[DataShare sharedService].userObject.minuteNumber] selectionHandler:^(RERadioItem *item) {
            [item deselectRowAnimated:YES];
            
        }];
        self.tiemItem.accessoryType = UITableViewCellAccessoryNone;
        [section3 addItem:self.tiemItem];
    }
    
    QWeakSelf(self);
    RETableViewSection *section13 = [RETableViewSection section];
    section13.footerHeight = 10;
    [self.manager addSection:section13];
    
    RERadioItem *pwdItem = [RERadioItem itemWithTitle:SetTitle(@"editPwd") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        PwdVC *vc = LOADVC(@"PwdVC");
        [weakself.navigationController pushViewController:vc animated:YES];
        vc = nil;
    }];
    [section13 addItem:pwdItem];
    
    
    if ([DataShare sharedService].userObject.type==0) {
        RETableViewSection *section4 = [RETableViewSection section];
        section4.footerHeight = 10;
        [_manager addSection:section4];
        RERadioItem *stockItem = [RERadioItem itemWithTitle:SetTitle(@"member") value:@"" selectionHandler:^(RERadioItem *item) {
            [item deselectRowAnimated:YES];
            
            MembersVC *vc = LOADVC(@"MembersVC");
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        [section4 addItem:stockItem];
    }
    /*
    QWeakSelf(self);
    RETableViewSection *section4 = [RETableViewSection section];
    section4.footerHeight = 10;
    [_manager addSection:section4];
    RERadioItem *stockItem = [RERadioItem itemWithTitle:SetTitle(@"authority_add") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        AuthorityVC *vc = LOADVC(@"AuthorityVC");
        vc.completedBlock = ^(BOOL success){
            weakself.tiemItem.value = [NSString stringWithFormat:SetTitle(@"Company_day"),(long)[DataShare sharedService].userObject.dayNumber,(long)[DataShare sharedService].userObject.hourNumber,(long)[DataShare sharedService].userObject.minuteNumber];
            
            [weakself.tiemItem reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        };
        [weakself.navigationController pushViewController:vc animated:YES];
    }];
    [section4 addItem:stockItem];
     */
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.headerImg.image = chosenImage;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVFile *attachment = [[AVUser currentUser] objectForKey:@"header"];
        if (attachment != nil) {
            [attachment deleteInBackground];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(self.headerImg.image,0.8);
        AVFile *imageFile = [AVFile fileWithName:@"header.png" data:imageData];
        
        [[AVUser currentUser] setObject:imageFile forKey:@"header"];
        [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[AVUser currentUser] refresh];
            UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
            [DataShare sharedService].userObject = user;
        }];
    });
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
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
