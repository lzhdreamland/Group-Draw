//
//  SessionManager.h
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/10/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

@import MultipeerConnectivity;

#import <Foundation/Foundation.h>

@protocol SessionClientProtocol
- (void) processData: (NSData *) data fromPeer: (MCPeerID *) peer;
@end

@interface SessionManager : NSObject <MCSessionDelegate>
@property (readonly,nonatomic) MCSession * session;
@property (strong,nonatomic) MCAdvertiserAssistant * advertiserAssistant;
@property (strong,nonatomic) id <SessionClientProtocol> client;

- (id) initWithDisplayName: (NSString *) displayName andServiceType: (NSString *) serviceType;
- (BOOL) hasPeers;

- (void) sendData: (NSData *) data;

@end
