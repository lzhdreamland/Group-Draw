//
//  User.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/4/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithCoder:(NSCoder *)aDecoder{
  NSLog(@"User initWithCoder");
  
  self = [super init];
  if (self) {
    self.userName = [aDecoder decodeObjectForKey:@"username"];
    self.marks = [aDecoder decodeObjectForKey:@"marks"];
    self.win = [aDecoder decodeObjectForKey:@"win"];
    self.lost = [aDecoder decodeObjectForKey:@"lost"];
    self.rates = [aDecoder decodeObjectForKey:@"rates"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
  NSLog(@"User encodeWithCoder");
  
  [aCoder encodeObject:self.userName forKey:@"username"];
  [aCoder encodeObject:self.marks forKey:@"marks"];
  [aCoder encodeObject:self.win forKey:@"win"];
  [aCoder encodeObject:self.lost forKey:@"lost"];
  [aCoder encodeObject:self.rates forKey:@"rates"];
}

@end
