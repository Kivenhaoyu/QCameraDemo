//
//  QN_uploadTakePhoto.m
//  QNAaronTest
//
//  Created by   何舒 on 15/10/18.
//  Copyright © 2015年   何舒. All rights reserved.
//

#import "QN_uploadTakePhoto.h"

@interface QN_uploadTakePhoto ()

@property (nonatomic, strong) UIImage * pickImage;
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * host;

@end

@implementation QN_uploadTakePhoto

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.uploadImage.contentMode = UIViewContentModeScaleAspectFit;
    self.showLabel.hidden = YES;
    
    self.prograssView.hidden = YES;
    self.prograssView.progress = 0.0f;
    
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
        [self uploadImageToQNFilePath:[self getImagePath:self.pickImage]];
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } andISstatus:NO andHeader:array];
}
- (IBAction)choseAction:(id)sender {
    [self gotoImageLibrary];
}

- (IBAction)uploadAction:(id)sender {
    
    if (!self.pickImage) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"还未选择资源图片" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }else
    {
        self.showLabel.hidden = NO;
        self.prograssView.hidden = NO;
        [self getTokenFromQN];
        
    }
    
    
}

/**
 *  调用系统相册
 */
-(void)gotoImageLibrary
{
    UIImagePickerController * imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:YES];
    [self.navigationController presentViewController:imgPicker animated:YES completion:^{
    }];
}

//再调用以下委托：
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.pickImage = image; //imageView为自己定义的UIImageView
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

//照片获取本地路径转换
-(NSString *)getImagePath:(UIImage *)Image
{
    NSString * filePath = nil;
    NSData * data = nil;
    if (UIImagePNGRepresentation(Image) == nil)
    {
        data = UIImageJPEGRepresentation(Image, 1.0);
    }
    else
    {
        data = UIImagePNGRepresentation(Image);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString * ImagePath = [[NSString alloc]initWithFormat:@"/theFirstImage.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,ImagePath];
    return filePath;
}

-(void)uploadImageToQNFilePath:(NSString *)filePath
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
    QNUploadOption * uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        self.percentFloat = percent;
    } params:nil checkCrc:NO cancellationSignal:nil];
    [upManager putFile:filePath key: self.key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
        NSLog(@"%@/%@",self.domain,resp[@"key"]);
        [self.uploadImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.host,resp[@"key"]]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField

{
    
    [self.fillKey resignFirstResponder];    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    
    return YES;
    
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
