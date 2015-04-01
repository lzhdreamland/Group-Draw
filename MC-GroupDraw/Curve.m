//
//  Curve.m
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/11/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "Curve.h"

@implementation Curve

- (void) draw {
  [self.color set];
  [self.path stroke];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
  NSLog(@"Curve initWithCoder");
  
  self = [super init];
  if (self) {
    self.color = [aDecoder decodeObjectForKey: @"color"];
    self.path = [aDecoder decodeObjectForKey: @"path"];
  }
  
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
  NSLog(@"Curve encodeWithCoder");
  
  [aCoder encodeObject: self.color forKey: @"color"];
  [aCoder encodeObject: self.path forKey: @"path"];
  
}

@end
