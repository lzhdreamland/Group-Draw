//
//  SessionManager.m
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/10/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "SessionManager.h"

@interface SessionManager ()

@end

@implementation SessionManager

#pragma mark MCSessionDelegate methods

- (NSString *) stringForState: (MCSessionState) state {
  switch (state) {
    case MCSessionStateConnected:
      return @"Connected";
    case MCSessionStateConnecting:
      return @"Connecting";
    case MCSessionStateNotConnected:
      return @"not Connected";
  }
}

- (void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
  NSLog(@"didReceiveData %d",(int)data.length);
  [self.client processData: data fromPeer: peerID];
}

- (void) session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
  NSLog(@"peerID %@ is %@",peerID.displayName,[self stringForState: state]);
}

#pragma mark SessionManager methods

- (BOOL) hasPeers {
  return (self.session.connectedPeers.count>0);
}

- (void) sendData: (NSData *) data {
  NSLog(@"sendData %d",(int)data.length);
  NSError * error;
  [self.session sendData: data toPeers: self.session.connectedPeers withMode:MCSessionSendDataReliable error: &error];
}

- (id) initWithDisplayName: (NSString *) displayName andServiceType: (NSString *) serviceType {
  self = [super init];
  if (self) {
    MCPeerID * peerID = [[MCPeerID alloc] initWithDisplayName: displayName];
    _session = [[MCSession alloc] initWithPeer: peerID securityIdentity: nil encryptionPreference: MCEncryptionRequired];
    _session.delegate = self;
    _advertiserAssistant = [[ MCAdvertiserAssistant alloc] initWithServiceType: serviceType discoveryInfo: nil session: _session];
    //[_advertiserAssistant start];
  }
  return self; 
}

@end
