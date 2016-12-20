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
    model.phoneVerified = object.mobilePhoneVerified;
    model.email = object.email;
    model.emailVerified = [[object objectForKey:@"emailVerified"]boolValue];
    
    model.type = [[object objectForKey:@"type"]integerValue];
    
    model.rule = [[object objectForKey:@"rule"] boolValue];
    
    model.tax = [[object objectForKey:@"tax"]integerValue];
    
    AVFile *attachment = [object objectForKey:@"header"];
    if (attachment != nil) {
        NSString *url = [attachment getThumbnailURLWithScaleToFit:true width:100 height:100];
        model.header = url;
    }
    
    model.expireDate = [[object objectForKey:@"expireDate"]doubleValue];
    
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:model.expireDate];
    
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitDay | NSCalendarUnitHour |NSCalendarUnitMinute fromDate:[NSDate date] toDate:confromTimesp options:0];
    
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    if (day<=0 && hour <=0 && minute<=0) {
        model.isExpire = true;
        
        day = 0;
        hour = 0;
        minute = 0;
    }
    
    model.dayNumber = day;
    model.hourNumber = hour;
    model.minuteNumber = minute;
    
    return model;
}

//[[NSDate date] timeIntervalSince1970]


@end
