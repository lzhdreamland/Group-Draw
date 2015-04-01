//
//  SettingsViewController.h
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/10/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

@import MultipeerConnectivity;

#import <UIKit/UIKit.h>

#import "SessionManager.h"

@protocol SettingsDelegateProtocol
- (void) settingsControllerDidFinish: (id) sender;
@end

@interface SettingsViewController : UIViewController
@property (strong,nonatomic) id <SettingsDelegateProtocol> delegate;
@property (strong,nonatomic) NSMutableDictionary * settings;
@end
