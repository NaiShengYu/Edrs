//
//  QRCodeReaderViewController.m
//  ZTOA
//
//  Created by linPeng on 15-7-25.
//
//

#import "QRCodeReaderViewController.h"
#import  "ModelLocator.h"
#import "MMDrawerBarButtonItem.h"
#import "InputBatchModel.h"
#import "UploadViewController2.h"
#import "SamplePlanModel.h"
@interface QRCodeReaderViewController (){
    UIImageView *lineImage ;
}

@end

@implementation QRCodeReaderViewController



#pragma mark Method 

- (void)moveline{
    CGRect frame = lineImage.frame ;
    frame.origin.y = frame.origin.y+10;
    if(frame.origin.y <280){
        lineImage.frame = frame;
    }else{
        lineImage.frame = CGRectMake(0, 0, 280, 6);
    }
    
}

- (void)checkAVAuthorizationStatus
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *tips =  @"您没有权限访问相机";
    
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        [self setupCamera];
    } else {
        [SVProgressHUD showErrorWithStatus:tips afterDelay:4];
        [self leftDrawerButtonPress:nil];
//        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:5];
    }
}

- (void)setupCamera
{
    // Device
    if(_device ==nil){
        self.view.backgroundColor = [UIColor whiteColor];
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // Session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        NSArray *array = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
        _output.metadataObjectTypes = array;
        // Preview
        _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    _preview.frame =CGRectMake(20,110,280,280);
        _preview.frame =CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        [self.view.layer insertSublayer:self.preview atIndex:0];
        
        UIView *boxView = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-280)/2,110,280,280)];
        boxView.backgroundColor = [UIColor clearColor];
        UIImageView *image1 =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
        image1.image = [UIImage imageNamed:@"ScanQR1.png"];
        [boxView addSubview:image1];
        UIImageView *image2 =[[UIImageView alloc]initWithFrame:CGRectMake(280-16, 0, 16, 16)];
        image2.image = [UIImage imageNamed:@"ScanQR2.png"];
        [boxView addSubview:image2];
        UIImageView *image3 =[[UIImageView alloc]initWithFrame:CGRectMake(0, 280-16, 16, 16)];
        image3.image = [UIImage imageNamed:@"ScanQR3.png"];
        [boxView addSubview:image3];
        UIImageView *image4 =[[UIImageView alloc]initWithFrame:CGRectMake(280-16, 280-16, 16, 16)];
        image4.image = [UIImage imageNamed:@"ScanQR4.png"];
        [boxView addSubview:image4];
        
        [self.view addSubview:boxView];
        
        lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, 6)];
        lineImage.image = [UIImage imageNamed:@"ff_QRCodeScanLine.png"];
        [boxView addSubview:lineImage];
        
        
        UILabel *titlelb = [[UILabel alloc]initWithFrame:CGRectMake(0, boxView.frame.origin.y+boxView.frame.size.height+20, SCREEN_WIDTH, 20)];
        titlelb.text = @"将二维码放入框内，即可自动扫描";
        titlelb.textColor = [UIColor whiteColor];
        titlelb.font = [UIFont systemFontOfSize:14];
        titlelb.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titlelb];
        
     
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveline) userInfo:nil repeats:YES];
        
        [self.timer fire];
    }
    
    // Start
    [_session startRunning];
}

- (void)cancelButtonClicked:(id)sender{
    [self.timer invalidate];
    self.timer = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark View

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)configuerTheNavigationLeftButton{
    UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,  50, 20)];
//    [cancleButton setImage:[UIImage imageNamed:@"back_fistpage"] forState:UIControlStateNormal];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancleButton];
    [self.navigationItem setLeftBarButtonItem:cancleItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(_isMenu){
        [self setupLeftMenuButton];
    }else{
        [self configuerTheNavigationLeftButton];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self checkAVAuthorizationStatus];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [_session stopRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    
    if(_isMenu){
        [self getPlanWith:stringValue];
    }else{
        [self.delegate getQRCodeWithSting:stringValue];
        __weak QRCodeReaderViewController *weakSelf = self ;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakSelf.timer invalidate];
            weakSelf.timer = nil;
        }];
    }
 
}


-(void)getQRcodeDetail:(NSString *)codeStr withSampleModel:(SamplePlanModel *)sampleModel{
   
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:codeStr forKey:@"qrcode"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:GET_PLAN_BYCODEDETAIL parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        
        @strongify(self);
       
        UploadViewController2 *uploadVC=[[UploadViewController2 alloc]init];
        uploadVC.planModel = sampleModel;
        uploadVC.qrcodeInfo =[dictionary valueForKey:@"list"];
        [self.navigationController pushViewController:uploadVC animated:YES];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getPlanWith:(NSString *)codeStr{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:codeStr forKey:@"qrcode"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:GET_PLAN_BYCODE parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        
        @strongify(self);
        NSArray *list = [dictionary valueForKey:@"list"];
        NSDictionary *dic = [list firstObject];
        SamplePlanModel *model = [[SamplePlanModel alloc]init];
        model.id = [dic valueForKey:@"planid"];
        model.refid = [dic valueForKey:@"disasterid"];
        model.lat = [[dic valueForKey:@"lat"] floatValue];
        model.lng = [[dic valueForKey:@"lng"]  floatValue];
        [self getQRcodeDetail:codeStr withSampleModel:model];
        
    } onError:^(NSError *engineError) {
        
    }];
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
