//
//  MessageModel.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "MessageModel.h"
#import "NSDate+Utils.h"

@implementation MessageModel

+(MessageModel *)messageFromDictionary:(NSDictionary *)aDic {
    MessageModel *message = [[MessageModel alloc]init];
    
    message.messageFrom = [aDic[@"messageFrom"]integerValue];
    message.messageTo = [aDic[@"messageTo"]integerValue];
    message.messageContent = aDic[@"messageContent"];
    message.messageType = [aDic[@"messageType"] integerValue];
    message.messageDate = aDic[@"messageDate"];
    
    if (message.messageFrom == [DataShare sharedService].userModel.userId) {
        message.fromType = WQMessageFromMe;
    }else {
        message.fromType = WQMessageFromOther;
    }
    
    return message;
}

//"08-10 晚上08:09:41.0" ->
//"昨天 上午10:09"或者"2012-08-10 凌晨07:09"
- (NSString *)changeTheDateString:(NSString *)Str {
    NSDate *lastDate = [NSDate dateFromString:Str withFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *dateStr;  //年月日
    NSString *period;   //时间段
    NSString *hour;     //时
    
    if ([lastDate year]==[[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {
            dateStr = [lastDate stringYearMonthDayCompareToday];
        }else{
            dateStr = [lastDate stringMonthDay];
        }
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }
    
    
    if ([lastDate hour]>=5 && [lastDate hour]<12) {
        period = @"AM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
        period = @"PM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
        period = NSLocalizedString(@"Night", @"");
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else{
        period = NSLocalizedString(@"Dawn", @"");
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }
    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
}

//显示日期与否
- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end {
    if (!start) {
        self.showDateLabel = YES;
        self.messageShowDate = [self changeTheDateString:self.messageDate];
        return;
    }
    
    NSDate *startDate = [NSDate dateFromString:start withFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *endDate = [NSDate dateFromString:end withFormat:@"yyyy-MM-dd HH:mm"];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距5分钟显示时间Label
    if (fabs (timeInterval) > 5*60) {
        self.showDateLabel = YES;
        self.messageShowDate = [self changeTheDateString:self.messageDate];
    }else{
        self.showDateLabel = NO;
    }
}


@end
