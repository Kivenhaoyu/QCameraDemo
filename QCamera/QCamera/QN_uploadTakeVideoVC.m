//
//  QN_uploadTakeVideoVC.m
//  QNAaronTest
//
//  Created by   何舒 on 15/10/18.
//  Copyright © 2015年   何舒. All rights reserved.
//

#import "QN_uploadTakeVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QN_PlayVideoVC.h"

@interface QN_uploadTakeVideoVC ()

@property (nonatomic, strong) NSString * videoPath;

@property (nonatomic, strong) ALAsset * asset;
@property (nonatomic, strong) ALAssetsLibrary * assetslibrary;

@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSTimer * transformTimer;
@property (nonatomic, strong) NSString *pipeline;
@property (nonatomic, assign) BOOL isCamera;
@property (nonatomic, strong) NSDictionary * transformDic;

@end

@implementation QN_uploadTakeVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"视频";
    self.uploadImage.contentMode = UIViewContentModeScaleAspectFit;
    self.showLabel.hidden = YES;
    self.prograssView.hidden = YES;
    self.transformView.hidden = YES;
    self.assetslibrary = [[ALAssetsLibrary alloc] init];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.transformTimer invalidate];
    [self.timer invalidate];
}

- (IBAction)takePhotoAction:(id)sender {
    [self stopTransform];
    [self gotoTakeVideo];
    self.isCamera = YES;
}

- (IBAction)takeLibraryPhotoAction:(id)sender
{
    [self stopTransform];
    [self gotoLibrary];
    self.isCamera = NO;
}
- (IBAction)uploadAction:(id)sender {
    [self stopTransform];
    self.transformDic = nil;
    [self.timer invalidate];
    if (!self.asset) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"还未选择资源图片" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
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
    self.key = [self.key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *device_id = [UserInfoClass sheardUserInfo].device_id;
    NSArray * array =[[NSArray alloc] initWithObjects:@"X-Qiniu-Key",self.key,@"X-Qiniu-Overwrite",@"false",@"X-Qiniu-Device-Id",device_id,@"X-Qiniu-Content-Type",@"av",nil];
    [HTTPRequestPost hTTPRequest_PUTpostBody:nil andUrl:@"upload/token" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        self.token = responseObject[@"token"];
        self.host = responseObject[@"host"];
        [self uploadImageAssetToQN];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } andISstatus:NO andHeader:array];
}

/**
 *  调用系统拍摄
 */
-(void)gotoTakeVideo
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

//打开本地相册
-(void)gotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

//再调用以下委托：
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset * asset)
    {
        self.asset = asset;
    };
    if (self.isCamera) {
        NSURL * videoURLString = [info valueForKey:UIImagePickerControllerMediaURL];
        [self.assetslibrary writeVideoAtPathToSavedPhotosAlbum:videoURLString completionBlock:^(NSURL *assetURL, NSError *error) {
            self.videoPath = [assetURL absoluteString];
            
            [self.assetslibrary assetForURL:assetURL resultBlock:resultBlock failureBlock:nil];
        }];
    }else{
        NSURL * videoURLString = [info valueForKey:UIImagePickerControllerReferenceURL];
    [self.assetslibrary assetForURL:videoURLString resultBlock:resultBlock failureBlock:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
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
        if (!info.error) {
            [self startTransform];
            self.pipeline = resp[@"pipeline"];
        }else
        {
            [SVProgressHUD showAlterMessage:[NSString stringWithFormat:@"%@",info.error.userInfo]];
        }

        
    } option:uploadOption];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getPercent) userInfo:nil repeats:YES];
    
}

- (void)stopTransform
{
    self.playView.hidden = NO;
    [self.transformTimer invalidate];
    self.transformView.hidden = YES;
    [self.tranformActivity stopAnimating];
}

- (void)startTransform
{
    int value = (arc4random() % 5) + 1;
    self.transformTimer = [NSTimer scheduledTimerWithTimeInterval:value target:self selector:@selector(checkTransform) userInfo:nil repeats:YES];
    self.transformView.hidden = NO;
    [self.tranformActivity startAnimating];
}

- (void)checkTransform
{
    [HTTPRequestPost hTTPRequest_PostpostBody:nil andUrl:[NSString stringWithFormat:@"pipeline/%@",self.pipeline] andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject == %@",responseObject );
        if ([responseObject[@"code"] isEqualToString:@"OperationProcessing"]) {
            //continue
        }else if([responseObject[@"code"] isEqualToString:@"OperationSuccess"])
        {
            self.transformDic = responseObject;
            [self stopTransform];
            [self uploadImageView];
            [SVProgressHUD showAlterMessage:@"转码成功"];
        }else
        {
            [self stopTransform];
            [SVProgressHUD showAlterMessage:@"转码失败"];
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        [self stopTransform];
    } andISstatus:NO];
}

- (void)uploadImageView
{
    NSArray * array =[[NSArray alloc] initWithObjects:@"X-Qiniu-Key",self.transformDic[@"cover"],nil];
    [HTTPRequestPost hTTPRequest_PUTpostBody:nil andUrl:@"download/url" andSucceed:^(NSURLSessionDataTask *task, id responseObject) {
        self.playView.hidden = NO;
        [self.playImage setImageWithURL:[NSURL URLWithString:responseObject[@"url"]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } andISstatus:NO andHeader:array];
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.fillKey resignFirstResponder];
}
- (IBAction)playAction:(id)sender {
    if (self.transformDic[@"mp4"]) {
        QN_PlayVideoVC * play = [[QN_PlayVideoVC alloc] initWithVideoName:self.transformDic[@"mp4"]];
        [self.navigationController pushViewController:play animated:YES];
    }else
    {
        [SVProgressHUD showAlterMessage:@"无法预览转码视频"];
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
