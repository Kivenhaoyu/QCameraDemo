//
//  ImageVC.h
//  QCamera
//
//  Created by   何舒 on 16/3/24.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "BaseVC.h"

@interface ImageVC : BaseVC

@property (weak, nonatomic) IBOutlet UIImageView * uploadImage;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSDictionary * dic;
- (instancetype)initWithDic:(NSDictionary *)dict;
@end
