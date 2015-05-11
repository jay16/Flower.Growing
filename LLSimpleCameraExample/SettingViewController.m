//
//  SettingViewController.m
//  LLSimpleCameraExample
//
//  Created by lijunjie on 15/5/10.
//  Copyright (c) 2015年 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingViewController.h"
#import "MyUtils.h"


@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fieldTimer;
@property (weak, nonatomic) IBOutlet UITextField *fieldCamera;
@property (weak, nonatomic) IBOutlet UIStepper *stepperTimer;
@property (weak, nonatomic) IBOutlet UIStepper *stepperCamera;

@end

@implementation SettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stepperTimer.minimumValue = 1;
    self.stepperTimer.maximumValue = 60;
    self.stepperTimer.stepValue    = 1;
    
    self.stepperCamera.minimumValue = 1;
    self.stepperCamera.maximumValue = 60;
    self.stepperCamera.stepValue    = 1;
    
    NSString *pathname = [MyUtils getConfigFilePath];
    NSMutableDictionary *config = [MyUtils readConfigFile:pathname];
    
    self.stepperTimer.value = [[config objectForKey:@"TimerInterval"] intValue]; // unit: minute
    self.stepperCamera.value = [[config objectForKey:@"CameraInterval"] intValue]; // unit: minute
    
    [self.stepperTimer addTarget:self action:@selector(stepperTimerValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.stepperCamera addTarget:self action:@selector(stepperCameraValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    self.fieldTimer.text = [NSString stringWithFormat:@"%d", (int)self.stepperTimer.value];
    self.fieldCamera.text = [NSString stringWithFormat:@"%d", (int)self.stepperCamera.value];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewTapped:(UIGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)stepperTimerValueChanged:(UIStepper *)sender {
    NSString *stepValue = [NSString stringWithFormat:@"%d", (int)sender.value];
    
    self.fieldTimer.text = stepValue;
    NSLog(@"TimerInterval: %@[m]", stepValue);
    
    NSString *pathname = [MyUtils getConfigFilePath];
    NSMutableDictionary *config = [MyUtils readConfigFile:pathname];
    [config setObject:stepValue forKey:@"TimerInterval"];
    [config writeToFile:[MyUtils getConfigFilePath] atomically:YES];
}

- (IBAction)stepperCameraValueChanged:(UIStepper *)sender {
    NSString *stepValue = [NSString stringWithFormat:@"%d", (int)sender.value];
    
    self.fieldCamera.text = stepValue;
    NSLog(@"CameraInterval: %@[m]", stepValue);
    
    NSString *pathname = [MyUtils getConfigFilePath];
    NSMutableDictionary *config = [MyUtils readConfigFile:pathname];
    [config setObject:stepValue forKey:@"CameraInterval"];
    [config writeToFile:[MyUtils getConfigFilePath] atomically:YES];
}



@end