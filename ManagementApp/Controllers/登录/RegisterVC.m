//
//  RegisterVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/10/24.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "RegisterVC.h"
#import "ChooseCountryVC.h"
#import "YJLocalCountryData.h"

#import "VerifiedVC.h"
#import "XLTextField.h"
@interface RegisterVC ()<UITextFieldDelegate,ChooseCountryVCDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,XLEmailTextFieldDelegate>{
//    SMSSDKCountryAndAreaCode* _data2;
}
@property (nonatomic, strong) NSMutableArray* areaArray;

@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UIView *line2;
@property (nonatomic, weak) IBOutlet UIView *line3;
@property (nonatomic, weak) IBOutlet UIView *line4;

@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UILabel *label3;
@property (nonatomic, weak) IBOutlet UILabel *label4;

@property (nonatomic, weak) IBOutlet UILabel *areaLab;
@property (nonatomic, weak) IBOutlet UILabel *countryLab;

@property (nonatomic, weak) IBOutlet UITextField *nameText;
@property (nonatomic, weak) IBOutlet UITextField *phoneText;
@property (nonatomic, weak) IBOutlet UITextField *pwdText;
@property (nonatomic, weak) IBOutlet XLTextField *emailText;

@property (nonatomic, strong) DeformationButton *registerBtn;

@property (nonatomic, weak) IBOutlet UIImageView *headerImg;
@property (nonatomic, strong) UIImage *header;
@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    [self setText];
    
    //设置本地区号
    [self setTheLocalAreaCode];
    
    //读取本地countryCode
    if (self.areaArray.count == 0) {
        NSMutableArray *dataArray = [YJLocalCountryData localCountryDataArray];
        
        self.areaArray = dataArray;
    }
}

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"register") image:nil];
    [self.view addSubview:self.navBarView];
}

-(void)setText {
    self.label1.text = SetTitle(@"company_name");
    self.label2.text = SetTitle(@"earth");
    self.label3.text = SetTitle(@"log_pwd");
    self.label4.text = SetTitle(@"email");
    [self.nameText setPlaceholder:SetTitle(@"company_name")];
    [self.emailText setPlaceholder:SetTitle(@"email")];
    [self.phoneText setPlaceholder:SetTitle(@"log_phone")];
    [self.pwdText setPlaceholder:SetTitle(@"log_pwd")];
    
    self.emailText.mailTypeArray = [NSMutableArray arrayWithObjects:@"@libero.it",@"@xxx.meh.es",@"@terra.es",@"@qq.com",@"@163.com",@"@126.com",@"@yahoo.com",@"@139.com", nil];
    self.emailText.customDelegate = self;
    
    [self registerBtn];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.registerBtn stopLoading];
}

#pragma mark - setter/getter

-(DeformationButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [[DeformationButton alloc]initWithFrame:(CGRect){15,303,SCREEN_WIDTH-30,40} withColor:kThemeColor];
        [_registerBtn.forDisplayButton setTitle:SetTitle(@"register") forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_registerBtn];
    }
    return _registerBtn;
}


#pragma mark - UITextFieldDelegate
- (void)XLTextFieldDidBeginEditing:(UITextField *)textField{
    self.line4.backgroundColor = kThemeColor;
    self.line1.backgroundColor = kLightGrayColor;
    self.line3.backgroundColor = kLightGrayColor;
    self.line2.backgroundColor = kLightGrayColor;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.nameText) {
        self.line1.backgroundColor = kThemeColor;
        self.line2.backgroundColor = kLightGrayColor;
        self.line3.backgroundColor = kLightGrayColor;
        self.line4.backgroundColor = kLightGrayColor;
    } else if (textField == self.phoneText){
        self.line2.backgroundColor = kThemeColor;
        self.line1.backgroundColor = kLightGrayColor;
        self.line3.backgroundColor = kLightGrayColor;
        self.line4.backgroundColor = kLightGrayColor;
    }else if (textField == self.emailText){
        self.line4.backgroundColor = kThemeColor;
        self.line1.backgroundColor = kLightGrayColor;
        self.line3.backgroundColor = kLightGrayColor;
        self.line2.backgroundColor = kLightGrayColor;
    }else if (textField == self.pwdText){
        self.line3.backgroundColor = kThemeColor;
        self.line1.backgroundColor = kLightGrayColor;
        self.line4.backgroundColor = kLightGrayColor;
        self.line2.backgroundColor = kLightGrayColor;
    }
}

- (void)XLTextFieldDidEndEditing:(UITextField *)textField {
    self.line4.backgroundColor = kLightGrayColor;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.nameText) {
        self.line1.backgroundColor = kLightGrayColor;
    } else if (textField == self.phoneText){
        self.line2.backgroundColor = kLightGrayColor;
    }else if (textField == self.emailText){
        self.line4.backgroundColor = kLightGrayColor;
    }else if (textField == self.pwdText){
        self.line3.backgroundColor = kLightGrayColor;
    }
}

- (BOOL)XLTextFieldShouldReturn:(UITextField *)textField {
    [self.pwdText becomeFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameText) {
        [self.emailText becomeFirstResponder];
    } else if (textField == self.phoneText){
        [self.emailText becomeFirstResponder];
    }else if (textField == self.emailText){
        [self.pwdText becomeFirstResponder];
    }else if (textField == self.pwdText){
        [self.pwdText resignFirstResponder];
    }
    return YES;
}


#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    self.line1.backgroundColor = kLightGrayColor;
    self.line2.backgroundColor = kLightGrayColor;
    self.line3.backgroundColor = kLightGrayColor;
    self.line4.backgroundColor = kLightGrayColor;
}

#pragma mark - action

//选择国家
-(IBAction)areaBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    ChooseCountryVC *vc = [[ChooseCountryVC alloc]init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

//- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
//{
//    _data2 = data;
//    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
//    
//    self.areaLab.text = [NSString stringWithFormat:@"+%@",data.areaCode];
//    self.countryLab.text = data.countryName;
//}

-(IBAction)registerBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    if (self.nameText.text.length==0) {
        //企业名称
        [PopView showWithImageName:nil message:SetTitle(@"company_name_error")];
        return;
    }
    
    if (self.emailText.text.length>0) {
        NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![pred evaluateWithObject:self.emailText.text]){
            [PopView showWithImageName:nil message:SetTitle(@"erroremail")];
            return;
        }
    }else if (self.emailText.text.length==0) {
        [PopView showWithImageName:nil message:SetTitle(@"erroremail")];
        return;
    }
    
    if (![self checkPassWord]) {
        //密码6-20位数字和字母组成
        [PopView showWithImageName:nil message:SetTitle(@"pwd_error")];
        return;
    }
    
    if ([DataShare sharedService].appDel.isReachable) {
        [self.registerBtn startLoading];
        self.registerBtn.enabled = NO;
        QWeakSelf(self);
        AVUser *user = [AVUser user];
        user.username = self.nameText.text;
        user.password =  self.pwdText.text;
        if (self.emailText.text.length>0) {
            user.email = self.emailText.text;
        }
        
        NSDate *date = [[NSDate date] dateByAddingTimeInterval:60*60*24*7];
        double time = [date timeIntervalSince1970];
        [user setObject:@(time) forKey:@"expireDate"];
        
        if (self.header) {
            NSData *imageData = UIImageJPEGRepresentation(self.header,0.8);
            AVFile *imageFile = [AVFile fileWithName:@"header.png" data:imageData];
            [imageFile save];
            [user setObject:imageFile            forKey:@"header"];
        }
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                AVUser *user = [AVUser currentUser];
                if (user != nil){
                    //登录成功---数据缓存到本地
                    [AVUser changeCurrentUser:user save:YES];
                    
                    [[AppDelegate shareInstance] saveUserInfo];
                    
                    if ([DataShare sharedService].userObject.email != nil) {
                        //验证页面
                        VerifiedVC *vc = LOADVC(@"VerifiedVC");
                        [weakself.navigationController pushViewController:vc animated:YES];
                        SafeRelease(vc);
                    }else {
                        [[AppDelegate shareInstance] showRootVCWithType:1];
                    }
                }
            }else {
                [PopView showWithImageName:nil message:error.userInfo[@"NSLocalizedDescription"]];
            }
            
            [weakself.registerBtn stopLoading];
            weakself.registerBtn.enabled = YES;
            
        }];
    }else {
        [PopView showWithImageName:nil message:SetTitle(@"no_connect")];
    }
}


-(void)setTheLocalAreaCode {
    self.areaLab.text = @"+39";
    self.countryLab.text = @"In Italia";
}


-(BOOL)checkPassWord {
    //6-20位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:self.pwdText.text]) {
        return YES ;
    }else
        return NO;
}

-(IBAction)selectedImage:(id)sender {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.headerImg.image = chosenImage;
    self.header = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
