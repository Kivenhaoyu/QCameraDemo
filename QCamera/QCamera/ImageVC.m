//
//  ImageVC.m
//  QCamera
//
//  Created by   何舒 on 16/3/24.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "ImageVC.h"

@interface ImageVC ()

@end

@implementation ImageVC

- (instancetype)initWithDic:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.dic = dict;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    [self.uploadImage addSubview:self.playBtn];
    self.title = self.dic[@"name"];
    [self uploadURL];
}

- (void)uploadURL
{
    NSArray * array =[[NSArray alloc] initWithObjects:@"X-Qiniu-Key",self.dic[@"name"],nil];
    [HTTPRequestPost hTTPRequest_PUTpostBody:nil andUrl:@"download/url" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        self.url = responseObject[@"url"];
        [self.uploadImage setImageWithURL:[NSURL URLWithString:self.url] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } andISstatus:NO andHeader:array];
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
