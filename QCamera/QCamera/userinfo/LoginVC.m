//
//  LoginVC.m
//  QNPilePlayDemo
//
//  Created by   何舒 on 15/11/4.
//  Copyright © 2015年   何舒. All rights reserved.
//

#import "LoginVC.h"
#import "ChooseBucketsVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.loginBtn.layer.cornerRadius = 10.0;
    self.passWordTextField.secureTextEntry = YES;
    
}

- (IBAction)LoginAction:(id)sender
{
    if (!self.userPhoneTextField.text) {
        [SVProgressHUD showAlterMessage:@"请输入账户名称"];
    }
    if (!self.passWordTextField.text) {
        [SVProgressHUD showAlterMessage:@"请输入密码"];
    }
    NSString * userName = self.userPhoneTextField.text;
    NSString * userPassword = self.passWordTextField.text;
    NSString * urlString = @"auth/token";
    NSDictionary * dic = @{@"username":userName,
                           @"password":userPassword,
                           @"device":[self uniqueAppInstanceIdentifier]};
    [HTTPRequestPost hTTPRequest_PostpostBody:dic andUrl:urlString andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject == %@",responseObject);
        [[UserInfoClass sheardUserInfo] setUserInfoLogin:userName withPassWord:userPassword withDevice_id:responseObject[@"device_id"] withAuthor_Token:responseObject[@"token"]];
        ChooseBucketsVC *chooseBuckets= [[ChooseBucketsVC alloc] init];
        [self presentViewController:chooseBuckets animated:YES completion:^{
        }];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } andISstatus:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/**
 * 获取deviceID
 */
- (NSString *)uniqueAppInstanceIdentifier
{
    NSString *app_uuid = @"";
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    app_uuid = [NSString stringWithString:(__bridge NSString *)uuidString];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    return app_uuid;
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
