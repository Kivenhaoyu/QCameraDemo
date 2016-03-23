//
//  UserInfoClass.h
//  QNPilePlayDemo
//
//  Created by   何舒 on 15/11/4.
//  Copyright © 2015年   何舒. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoClass : NSObject
@property(nonatomic,assign)BOOL isLogin;
#pragma mark 用户信息

@property (nonatomic, strong) NSString * userCount;
@property (nonatomic, strong) NSString * passWord;
@property (nonatomic, strong) NSString * device_id;
@property (nonatomic, strong) NSString * author_token;
@property (nonatomic, strong) NSString * bucket;
+(instancetype)sheardUserInfo;

- (void)setUserInfoLogin:(NSString *)userPhone
            withPassWord:(NSString *)passWord
           withDevice_id:(NSString *)device_id
        withAuthor_Token:(NSString *)author_token;

- (void)setTheBucket:(NSString *)bucket;

- (void)userLogout;

@end
