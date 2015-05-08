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

#define TIMER_INTERVAL   5
#define CAPTURE_INTERVAL 300
@interface HomeViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) NSTimer  *timer;
@property (nonatomic,assign) NSInteger counter;
@property (nonatomic,assign) NSInteger interval;
@property (nonatomic,assign) BOOL      save_state;
@property (nonatomic,assign) NSInteger save_counter;

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
    self.snapButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
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
    
    // button to toggle camera positions
    self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
    [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
    self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:self.switchButton];
    
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(dealWithCaculate) userInfo:nil repeats:YES];
    self.counter      = 0;
    self.save_state   = true;
    self.save_counter = 0;
}

// 页面将要进入前台，开启定时器
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
    // 开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
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
}

/* camera delegates */
- (void)cameraViewController:(LLSimpleCamera *)cameraVC didCaptureImage:(UIImage *)image {
    
    // we should stop the camera, since we don't need it anymore. We will open a new vc.
    NSLog(@"Camera stop");
    [self.camera stop];
    
    NSLog(@"save to photos");
    [self saveImageToPhotos:image];
    if(self.save_state) self.save_counter = self.save_counter + 1;
    
    NSLog(@"Camera start");
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
    self.save_state = (error != NULL);
}

- (void) dealWithCaculate {
    self.counter = self.counter + 5;
    NSInteger rest = self.counter % CAPTURE_INTERVAL;
    
    if(rest == 0) [self.camera capture];
    
    rest = CAPTURE_INTERVAL - rest;
    [self.snapButton setTitle:[NSString stringWithFormat:@"%li[%li]", (long)rest,(long)self.save_counter] forState:UIControlStateNormal];
    NSLog(@"timer: %li",(long)rest);
}
@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
