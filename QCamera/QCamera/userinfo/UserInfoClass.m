//
//  UserInfoClass.m
//  QNPilePlayDemo
//
//  Created by   何舒 on 15/11/4.
//  Copyright © 2015年   何舒. All rights reserved.
//

#define USER @"UserInfoClass"

#import "UserInfoClass.h"

static UserInfoClass *_userInfo=nil;

@implementation UserInfoClass
+ (instancetype)sheardUserInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _userInfo = [[UserInfoClass alloc] init];
        NSData *data=[[NSUserDefaults standardUserDefaults] objectForKey:USER];
        NSDictionary *dict;
        if(!data)
            return ;
        dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        _userInfo.device_id=[[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
        _userInfo.author_token=[[NSUserDefaults standardUserDefaults] objectForKey:@"author_token"];
        _userInfo.bucket = [[NSUserDefaults standardUserDefaults] objectForKey:@"bucket"];
        
        NSString *userCount=dict[@"userCount"];
        
        if(userCount)
        {
            [_userInfo setValuesForKeysWithDictionary:dict];
            _userInfo.isLogin=YES;
        }else
        {
            _userInfo.isLogin=NO;
        }
        
    });
    return _userInfo;
}

- (void)setUserInfoLogin:(NSString *)userCount
            withPassWord:(NSString *)passWord
           withDevice_id:(NSString *)device_id
        withAuthor_Token:(NSString *)author_token
{
    NSDictionary * dict = @{@"userCount":userCount,
                            @"passWord":passWord,};
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
#pragma markfabuCount
    if (device_id) {
        [[NSUserDefaults standardUserDefaults] setObject:device_id forKey:@"device_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (author_token) {
        [[NSUserDefaults standardUserDefaults] setObject:author_token forKey:@"author_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.isLogin=YES;
    [self setValuesForKeysWithDictionary:dict];
    self.device_id = device_id;
    self.author_token = author_token;
}

- (void)setTheBucket:(NSString *)bucket
{
    if (bucket) {
        [[NSUserDefaults standardUserDefaults] setObject:bucket forKey:@"bucket"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.bucket = bucket;
    }
}

- (void)userLogout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"author_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"bucket"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _userInfo.device_id = @"";
    _userInfo.author_token = @"";
    _userInfo.bucket = @"";
    _userInfo.userCount = @"";
    _userInfo.passWord = @"";
    
    self.isLogin=NO;
    
}

@end
