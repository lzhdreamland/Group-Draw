//
//  ConnectivityViewController.h
//  MC-GroupDraw
//
//  Created by ZihaoLin on 11/23/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//
@import MultipeerConnectivity;

#import <UIKit/UIKit.h>

#import "SessionManager.h"

@protocol ConnectivityDelegateProtocol
  -(void) connectivityControllerDidFinish: (id) sender;
@end

@interface ConnectivityViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MCBrowserViewControllerDelegate>
@property (strong, nonatomic) id<SessionClientProtocol ,ConnectivityDelegateProtocol> delegate;
@property (strong, nonatomic) SessionManager * sessionMngr;

@end
