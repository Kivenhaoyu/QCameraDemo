//
//  QN_uploadTakeVideoVC.h
//  QNAaronTest
//
//  Created by   何舒 on 15/10/18.
//  Copyright © 2015年   何舒. All rights reserved.
//

#import "BaseVC.h"

@interface QN_uploadTakeVideoVC : BaseVC<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *choseBtn;
@property (weak, nonatomic) IBOutlet UIButton *choseFromLibraryBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIImageView * uploadImage;
@property (weak, nonatomic) IBOutlet UIProgressView *prograssView;
@property (weak, nonatomic) IBOutlet UITextField *fillKey;
@property (weak, nonatomic) IBOutlet UIView *transformView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tranformActivity;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIImageView *playImage;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end
