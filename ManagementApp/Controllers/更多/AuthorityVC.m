//
//  AuthorityVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/11/11.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AuthorityVC.h"

#import "RETableViewManager.h"
#import "NSDate+Utils.h"

@interface AuthorityVC ()

@property (nonatomic, weak) IBOutlet UITableView *table;
@property (strong, nonatomic) RETableViewManager *manager;


@property (strong, readwrite, nonatomic) REDateTimeItem *dateTimeItem;

@property (strong, readwrite, nonatomic) RETextItem *priceItem;

@property (nonatomic, assign) CGFloat price;

@property (nonatomic, assign) CGFloat currentPrice;

@property (strong, nonatomic) NSDate *selectedDate;
@end

@implementation AuthorityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    if ([DataShare sharedService].appDel.isReachable) {
        AVQuery *query = [AVQuery queryWithClassName:@"UnitPrice"];
        AVObject *obj = [query getFirstObject];
        
        self.price = [[obj objectForKey:@"price"] floatValue];
        
        self.currentPrice = self.price;
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
    
    _manager = [[RETableViewManager alloc] initWithTableView:self.table];
    RETableViewSection *section = [RETableViewSection section];
    [_manager addSection:section];
    
    [[AVUser currentUser] refresh];
    UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
    [DataShare sharedService].userObject = user;
    
    //至少1天
    NSDate *date;
    if ([Utility isAuthority]) {
        date = [NSDate dateWithTimeIntervalSince1970:[DataShare sharedService].userObject.expireDate];
        date = [date dateByAddingTimeInterval:60*60*24*1];
    }else {
        date = [[NSDate date] dateByAddingTimeInterval:60*60*24*1];
    }

    QWeakSelf(self);
    self.dateTimeItem = [REDateTimeItem itemWithTitle:SetTitle(@"Company_date") value:date placeholder:nil format:@"MM/dd/yyyy hh:mm" datePickerMode:UIDatePickerModeDateAndTime];
    self.dateTimeItem.onChange = ^(REDateTimeItem *item){
        
        weakself.selectedDate = item.value;
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:NSCalendarUnitDay | NSCalendarUnitHour |NSCalendarUnitMinute fromDate:date toDate:item.value options:0];
        
        NSInteger day = [components day];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        weakself.currentPrice = weakself.price +weakself.price*day +weakself.price/24*hour +weakself.price/24/60*minute;
        
        weakself.priceItem.value = [NSString stringWithFormat:@"%.2f",weakself.currentPrice];

        [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
    };
    self.dateTimeItem.minimumDate = date;
    self.dateTimeItem.inlineDatePicker = YES;
    [section addItem:self.dateTimeItem];

    
    self.priceItem = [RETextItem itemWithTitle:SetTitle(@"price") value:[NSString stringWithFormat:@"%.2f",self.currentPrice] placeholder:QString(@"0")];
    self.priceItem.enabled = false;
    self.priceItem.alignment = NSTextAlignmentRight;
    [section addItem:self.priceItem];
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"authority_add") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    [self.view addSubview:self.navBarView];
    
    [Utility setExtraCellLineHidden:self.table];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    [self.view endEditing:YES];
    
    
    NSDate *date;
    if ([Utility isAuthority]) {
        date = [NSDate dateWithTimeIntervalSince1970:[DataShare sharedService].userObject.expireDate];
        date = [date dateByAddingTimeInterval:60*60*24*1];
    }else {
        date = [[NSDate date] dateByAddingTimeInterval:60*60*24*1];
    }
    
    double time;
    NSString *timeString;
    if (self.selectedDate) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:NSCalendarUnitDay | NSCalendarUnitHour |NSCalendarUnitMinute fromDate:date toDate:self.selectedDate options:0];
        
        NSInteger day = [components day];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        self.currentPrice = self.price +self.price*day +self.price/24*hour +self.price/24/60*minute;
        if (self.currentPrice<1) {
            self.currentPrice = 1;
        }
        time = [self.selectedDate timeIntervalSince1970];
        timeString = [self.selectedDate stringCutSeconds];
    }else {
        time = [date timeIntervalSince1970];
        timeString = [date stringCutSeconds];
    }
    
    QWeakSelf(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_add") message:[NSString stringWithFormat:@"%@:%@\n%@:%.2f",SetTitle(@"Company_date"),timeString,SetTitle(@"price"),self.currentPrice] preferredStyle:UIAlertControllerStyleAlert];
    [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
        [[AVUser currentUser] setObject:@(time) forKey:@"expireDate"];
        [[AVUser currentUser] save];
        
        [[AVUser currentUser] refresh];
        UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
        [DataShare sharedService].userObject = user;
        
        AVQuery *consumption = [AVQuery queryWithClassName:@"Consumption"];
        [consumption whereKey:@"user" equalTo:[AVUser currentUser]];
        AVObject *consumption_post = [consumption getFirstObject];
        if (!consumption_post) {
            consumption_post = [AVObject objectWithClassName:@"Consumption"];
            [consumption_post setObject:[AVUser currentUser] forKey:@"user"];
        }
        [consumption_post incrementKey:@"price" byAmount:[NSNumber numberWithFloat:weakself.currentPrice]];
        [consumption_post save];
        
        
        if (weakself.completedBlock) {
            weakself.completedBlock(YES);
        }
        
        [weakself.navigationController popViewControllerAnimated:YES];
    }];
    [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
    [self presentViewController:alert animated:YES completion:nil];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
