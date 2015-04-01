//
//  Curve.h
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/11/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Curve : NSObject <NSCoding>
@property (strong,nonatomic) UIBezierPath * path;
@property (strong,nonatomic) UIColor * color;

- (void) draw;

@end
