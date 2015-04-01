//
//  Clocker.h
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/5/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Clocker : UIView
@property (assign) float length;
@property (assign) float speed;
@property (assign) BOOL clockwise;
@property (assign) NSString *time;
@property (assign) int initTime;

- (id) initWithTimeLimit:(int) timeLimit;
- (void) updateTimeCalculation;
- (void) update;
@end
