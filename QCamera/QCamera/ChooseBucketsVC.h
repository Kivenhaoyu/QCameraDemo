//
//  ChooseBucketsVC.h
//  QCamera
//
//  Created by   何舒 on 16/3/23.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "BaseVC.h"

@interface ChooseBucketsVC : BaseVC<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic ,assign) BOOL ischange;
@property (weak, nonatomic) IBOutlet UIButton *backbtn;
//@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end
