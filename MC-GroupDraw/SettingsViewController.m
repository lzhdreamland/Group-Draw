//
//  SettingsViewController.m
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/10/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

@import MultipeerConnectivity;

#import "SettingsViewController.h"
#import "SessionManager.h"
#import "PathSampleView.h"

@interface SettingsViewController () {
//  IBOutlet UITableView * peerTable;
  IBOutlet UISlider * lineWidthSlider;
  IBOutlet UISlider * redSlider;
  IBOutlet UISlider * greenSlider;
  IBOutlet UISlider * blueSlider;
  IBOutlet PathSampleView * pathSampleView;
  NSTimer * reloadTimer;
}
@end

@implementation SettingsViewController

#pragma mark Action methods

- (IBAction) takeColorFrom: (UISlider *) sender {
  self.settings[@"strokeColor"] = [UIColor colorWithRed: redSlider.value green: greenSlider.value blue: blueSlider.value alpha: 1.0];
  [pathSampleView setNeedsDisplay];
}

- (IBAction) takeWidthFrom: (UISlider *) sender {
  self.settings[@"strokeWidth"] = [NSNumber numberWithDouble: [sender value]];
  [pathSampleView setNeedsDisplay];
}

- (IBAction) done: (id) sender {
  [reloadTimer invalidate];
  [self.delegate settingsControllerDidFinish: self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSLog(@"viewDidLoad");
  
  double r, g, b, a;
  UIColor * color = self.settings[@"strokeColor"];
  [color getRed: &r green: &g blue: &b alpha: &a];
  redSlider.value = r;
  greenSlider.value = g;
  blueSlider.value = b;
  
  lineWidthSlider.value = ((NSNumber *)self.settings[@"strokeWidth"]).doubleValue;
  
  pathSampleView.settings = self.settings;
  [pathSampleView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
