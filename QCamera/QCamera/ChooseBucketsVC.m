//
//  ChooseBucketsVC.m
//  QCamera
//
//  Created by   何舒 on 16/3/23.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "ChooseBucketsVC.h"
#import "MJRefresh.h"

@interface ChooseBucketsVC ()
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation ChooseBucketsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] init];
    [self setupRefresh];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //#warning 自动刷新(一进入程序就下拉刷新)
    [self.tableView headerBeginRefreshing];
    
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
    [HTTPRequestPost hTTPRequest_GetpostBody:nil andUrl:@"bucket" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject == %@",responseObject);
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:responseObject];
        [self.tableView reloadData];
        [self setEndhead];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        [self setEndhead];
    } andISstatus:NO andHeader:nil];
}
#pragma mark 上拉加载
- (void)footerRereshing
{
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:@"暂无更多数据"];
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self setEndFoot];
    });
    
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
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UserInfoClass sheardUserInfo] setTheBucket:self.dataArray[indexPath.row]];
    if (self.ischange) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
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
