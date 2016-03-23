//
//  QUploadVC.m
//  QCamera
//
//  Created by   何舒 on 16/3/23.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "QUploadVC.h"
#import "LoginVC.h"
#import "MJRefresh.h"
#import "QN_uploadTakePhoto.h"
#import "QN_uploadTakeVideoVC.h"
#import "QN_PlayVideoVC.h"
#import "ImageVC.h"
#import "ChooseBucketsVC.h"

@interface QUploadVC ()

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSString * marker;

@end

@implementation QUploadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc] init];
    [self setupRefresh];
    // Do any additional setup after loading the view from its nib.
    if (![UserInfoClass sheardUserInfo].isLogin) {
        LoginVC * loginVC = [[LoginVC alloc] init];
        [self presentViewController:loginVC animated:YES completion:^{
        }];
    }else{
        [self.tableView headerBeginRefreshing];
    }
    self.title = @"上传记录";
    UIBarButtonItem * logout = [[UIBarButtonItem alloc] initWithTitle:@"logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = logout;
    
    UIBarButtonItem * changebucket = [[UIBarButtonItem alloc] initWithTitle:@"Cbucket" style:UIBarButtonItemStylePlain target:self action:@selector(changebucket)];
    self.navigationItem.leftBarButtonItem = changebucket;
}

- (void)logout
{
    [[UserInfoClass sheardUserInfo] userLogout];
    LoginVC * loginVC = [[LoginVC alloc] init];
    [self presentViewController:loginVC animated:YES completion:^{
    }];
}

- (void)changebucket
{
    ChooseBucketsVC * chooseVC = [[ChooseBucketsVC alloc] init];
    chooseVC.ischange = YES;
    [self presentViewController:chooseVC animated:YES completion:^{
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    if ([UserInfoClass sheardUserInfo].isLogin) {
        [self.tableView headerBeginRefreshing];
    }
    
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //#warning 自动刷新(一进入程序就下拉刷新)
//    [self.tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉可以刷新";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新";
    self.tableView.headerRefreshingText = @"刷新中";
    
    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据";
    self.tableView.footerRefreshingText = @"加载中";
}
#pragma mark 下拉刷新
- (void)headerRereshing
{
    [HTTPRequestPost hTTPRequest_GetpostBody:nil andUrl:@"object" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject == %@",responseObject);
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:responseObject[@"items"]];
        self.marker = responseObject[@"marker"];
        [self.tableView reloadData];
        [self setEndhead];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        [self setEndhead];
    } andISstatus:NO andHeader:nil];
    
}
#pragma mark 上拉加载
- (void)footerRereshing
{
    NSDictionary * dic = @{@"marker":self.marker};
    
    [HTTPRequestPost hTTPRequest_GetpostBody:dic andUrl:@"object" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject == %@",responseObject);
        [self.dataArray addObjectsFromArray:responseObject[@"items"]];
        self.marker = responseObject[@"marker"];
        [self.tableView reloadData];
        [self setEndFoot];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        [self setEndFoot];
    } andISstatus:NO andHeader:nil];
    
}

-(void)setEndhead;
{
    [self.tableView headerEndRefreshing];
}
-(void)setEndFoot;
{
    [self.tableView footerEndRefreshing];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellName = @"UPLOADCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.textLabel.text = self.dataArray[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!([self.dataArray[indexPath.row][@"mime"] rangeOfString:@"video"].location == NSNotFound))
    {
        QN_PlayVideoVC * play = [[QN_PlayVideoVC alloc] initWithDic:self.dataArray[indexPath.row]];
        [self.navigationController pushViewController:play animated:YES];
    }else if (!([self.dataArray[indexPath.row][@"mime"] rangeOfString:@"image"].location == NSNotFound))
    {
        ImageVC * imagevc = [[ImageVC alloc] initWithDic:self.dataArray[indexPath.row]];
        [self.navigationController pushViewController:imagevc animated:YES];
    }else{
        [SVProgressHUD showAlterMessage:@"当前文件不支持预览"];
    }
}

- (IBAction)uploadImage:(id)sender
{
    QN_uploadTakePhoto * takePhoto = [[QN_uploadTakePhoto alloc] init];
    [self.navigationController pushViewController:takePhoto animated:YES];
}


- (IBAction)uploadVideo:(id)sender
{
    QN_uploadTakeVideoVC * takevideo = [[QN_uploadTakeVideoVC alloc] init];
    [self.navigationController pushViewController:takevideo animated:YES];
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
