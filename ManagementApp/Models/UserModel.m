//
//  UserModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/25.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+(UserModel *)initWithObject:(AVUser *)object {
    UserModel *model = [[UserModel alloc]init];
    
    model.userId = object.objectId;
    model.userName = object.username;
    model.phone = object.mobilePhoneNumber;
    model.email = object.email;
    model.day = [[object objectForKey:@"day"]integerValue];
    model.isExpire = [[object objectForKey:@"expire"]boolValue];
    model.createdAt = object.createdAt;
    
    AVFile *attachment = [object objectForKey:@"header"];
    if (attachment != nil) {
        model.userHead = [attachment getThumbnailURLWithScaleToFit:true width:120 height:120];
    }

    return model;
}

-(BOOL)checkExpire {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self.createdAt toDate:[NSDate date] options:0];
    
    NSInteger day = [components day];
    
    if (self.day-day<=0) {
        return true;
    }
    return false;
}

-(NSString *)dayString {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self.createdAt toDate:[NSDate date] options:0];
    
    NSInteger day1 = [components day];
    
    if ([self checkExpire]) {
        return SetTitle(@"Company_expire");
    }else {
        return [NSString stringWithFormat:@"%ld%@",self.day-day1,SetTitle(@"Company_day")];
    }
}

-(NSString *)dayNumber {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self.createdAt toDate:[NSDate date] options:0];
    
    NSInteger day1 = [components day];
    
    if ([self checkExpire]) {
        return @"0";
    }else {
        return [NSString stringWithFormat:@"%ld",self.day-day1];
    }
}
@end
