//
//  QUploadVC.h
//  QCamera
//
//  Created by   何舒 on 16/3/23.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "BaseVC.h"

@interface QUploadVC : BaseVC<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIButton * uploadImage;
@property (weak, nonatomic) IBOutlet UIButton * uploadVideo;

@end
