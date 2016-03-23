//
//  QN_uploadTakeVideoVC.m
//  QNAaronTest
//
//  Created by   何舒 on 15/10/18.
//  Copyright © 2015年   何舒. All rights reserved.
//

#import "QN_uploadTakeVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface QN_uploadTakeVideoVC ()

@property (nonatomic, strong) NSString * videoPath;

@property (nonatomic, strong) ALAsset * asset;
@property (nonatomic, strong) ALAssetsLibrary * assetslibrary;

@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * host;

@end

@implementation QN_uploadTakeVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.functionTitle;
    self.uploadImage.contentMode = UIViewContentModeScaleAspectFit;
    self.showLabel.hidden = YES;
    
    self.prograssView.hidden = YES;
    self.prograssView.progress = 0.0f;
    
    self.assetslibrary = [[ALAssetsLibrary alloc] init];
    
}

- (IBAction)takePhotoAction:(id)sender {
    [self gotoImageLibrary];
}
- (IBAction)uploadAction:(id)sender {
    if (!self.asset) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"还未选择资源图片" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }else
    {
        self.showLabel.hidden = NO;
        self.prograssView.hidden = NO;
        [self getTokenFromQN];
        
    }
}

-(void)getTokenFromQN
{
    if ([self.fillKey.text isEqualToString:@""]) {
        [SVProgressHUD showAlterMessage:@"请填写文件名称"];
        return;
    }
    self.key = self.fillKey.text;
    NSString *device_id = [UserInfoClass sheardUserInfo].device_id;
    NSArray * array =[[NSArray alloc] initWithObjects:@"X-Qiniu-Key",self.key,@"X-Qiniu-Overwrite",@"false",@"X-Qiniu-Device-Id",device_id,nil];
    [HTTPRequestPost hTTPRequest_PUTpostBody:nil andUrl:@"upload/token" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        self.token = responseObject[@"token"];
        self.host = responseObject[@"host"];
        [self uploadImageAssetToQN];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } andISstatus:NO andHeader:array];
}

/**
 *  调用系统相册
 */
-(void)gotoImageLibrary
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.mediaTypes = [[NSArray alloc] initWithObjects:temp_MediaTypes[1], nil];
        picker.delegate = self;
        picker.allowsEditing = YES;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

//再调用以下委托：
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    NSString * videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset * asset)
    {
        self.asset = asset;
    };
    [self.assetslibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
        self.videoPath = assetURL;
        [self.assetslibrary assetForURL:self.videoPath resultBlock:resultBlock failureBlock:nil];
    }];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)uploadImageAssetToQN
{
    NSString * token = @"";
    if (!isStringEmpty(self.token)) {
        token = self.token;
    }
    QNConfiguration * config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        if (!([self.host rangeOfString:@"z0"].location == NSNotFound)) {
            builder.zone = [QNZone zone0];
        }else
        {
            builder.zone = [QNZone zone1];
        }
    }];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    
    //当上传的文件名字一样时，默认为上传失败
//    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption * uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        self.percentFloat = percent;
    } params:nil checkCrc:NO cancellationSignal:nil];
    
    [upManager putALAsset:self.asset key:self.fillKey.text token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
        
        NSLog(@"%@/%@",self.domain,key);
        
    } option:uploadOption];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getPercent) userInfo:nil repeats:YES];
    
}

- (void)getPercent
{
    if (self.percentFloat == 1.00) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.showLabel.text = [NSString stringWithFormat:@"%.0f%%",self.percentFloat*100];
    self.prograssView.progress = self.percentFloat;
    [self.showLabel setNeedsLayout];
    
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
