//
//  HomeViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewUtils.h"
#import "ImageViewController.h"
#import "SettingViewController.h"
#import "MyUtils.h"


@interface HomeViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UILabel *lastLabel;
@property (strong, nonatomic) NSTimer  *timer;
@property (nonatomic,assign) NSInteger counter;
@property (nonatomic,assign) NSInteger save_counter;
@property (nonatomic,assign) BOOL      save_state;
@property (nonatomic,assign) NSInteger timerInterval;
@property (nonatomic,assign) NSInteger cameraInterval;
@property (strong, nonatomic)  NSMutableDictionary *myConfig;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:CameraQualityPhoto];
    
    // attach to the view and assign a delegate
    [self.camera attachToViewController:self withDelegate:self];
    
    // set the camera view frame to size and origin required for your app
    self.camera.view.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = YES;

    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [[UIButton alloc] init];//buttonWithType:UIButtonTypeSystem];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.snapButton setTitle:@"YES" forState:UIControlStateNormal];
    [self.snapButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    self.snapButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.snapButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 24.0f + 20.0f);
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash-off.png"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash-on.png"] forState:UIControlStateSelected];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:self.flashButton];
    
    self.lastLabel = [[UILabel alloc] init];
    self.lastLabel.frame = CGRectMake(screenRect.size.width/2, screenRect.size.height/2, 16.0f + 120.0f, 24.0f + 0.0f);
    self.lastLabel.text = @"hello world";
    self.lastLabel.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview: self.lastLabel];
    
    // button to toggle camera positions
    self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
    [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
    self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.switchButton addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:self.switchButton];
    
    // button to toggle camera positions
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
    [self.settingButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
    self.settingButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.settingButton addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingButton];
    
    self.myConfig = [MyUtils readConfigFile:[MyUtils getConfigFilePath]];
    NSLog(@"View Did Load: %@", self.myConfig);
    
    self.timerInterval = [[self.myConfig objectForKey:@"TimerInterval"] intValue] * 60;
    self.cameraInterval = [[self.myConfig objectForKey:@"CameraInterval"] intValue] * 60;
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(dealWithCaculate) userInfo:nil repeats:YES];
    self.counter      = 0;
    self.save_counter = 0;
    self.save_state    = true;
}

// 页面将要进入前台，开启定时器
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
    
    // 永久取消定时器
    [self.timer invalidate];
    // 一定要将 timer 赋空，否则还是没有释放
    self.timer = nil;
    
    self.myConfig = [MyUtils readConfigFile:[MyUtils getConfigFilePath]];
    
    self.timerInterval = [[self.myConfig objectForKey:@"TimerInterval"] intValue] * 60;
    self.cameraInterval = [[self.myConfig objectForKey:@"CameraInterval"] intValue] * 60;
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(dealWithCaculate) userInfo:nil repeats:YES];
    NSLog(@"View Come Back: %@", self.myConfig);

}

// 页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated {
    // 关闭定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

/* camera buttons */
- (void)switchButtonPressed:(UIButton *)button {
    [self.camera togglePosition];
}

/* camera buttons */
- (void)settingButtonPressed:(UIButton *)button {
    NSLog(@"presentViewController: SettingView");
    
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self presentViewController:settingVC animated:NO completion:nil];
}

- (void)flashButtonPressed:(UIButton *)button {
    
    CameraFlash flash = [self.camera toggleFlash];
    if(flash == CameraFlashOn) {
        self.flashButton.selected = YES;
    }
    else {
        self.flashButton.selected = NO;
    }
}

- (void)snapButtonPressed:(UIButton *)button {
    // capture the image, delegate will be executed
    [self.camera capture];
    
    
    [self.snapButton setTitle:[NSString stringWithFormat:@"%li[%@]", (long)self.save_counter,self.save_state ? @"y" : @"n"] forState:UIControlStateNormal];
}

/* camera delegates */
- (void)cameraViewController:(LLSimpleCamera *)cameraVC didCaptureImage:(UIImage *)image {
    
    // we should stop the camera, since we don't need it anymore. We will open a new vc.
    [self.camera stop];
    
    [self saveImageToPhotos:image];
    if(self.save_state) self.save_counter = self.save_counter + 1;
    
    [self.camera start];
    //ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
    //[self presentViewController:imageVC animated:NO completion:nil];
}

- (void)cameraViewController:(LLSimpleCamera *)cameraVC didChangeDevice:(AVCaptureDevice *)device {
    
    // device changed, check if flash is available
    if(cameraVC.isFlashAvailable) {
        self.flashButton.hidden = NO;
    }
    else {
        self.flashButton.hidden = YES;
    }
    
    self.flashButton.selected = NO;
}

/* other lifecycle methods */
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height - 15;
    
    self.flashButton.center = self.view.contentCenter;
    self.flashButton.top = 5.0f;
    
    self.switchButton.top = 5.0f;
    self.switchButton.right = self.view.width - 5.0f;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;//UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)saveImageToPhotos:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString *msg = [NSString stringWithFormat:@"保存图片:%@", (error != NULL ? @"失败" : @"成功") ];
    NSLog(@"%@", msg);
    self.save_state = (error == NULL);
    
    if(error!=NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) dealWithCaculate {
    self.counter = self.counter + self.timerInterval;
    NSInteger rest = self.counter % self.cameraInterval;
    
    if(rest == 0) [self.camera capture];
    [self.snapButton setTitle:[NSString stringWithFormat:@"%li[%@]", (long)self.save_counter,self.save_state ? @"y" : @"n"] forState:UIControlStateNormal];
    //[self.camera start];
}
@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
