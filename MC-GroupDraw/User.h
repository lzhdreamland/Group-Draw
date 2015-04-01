//
//  User.h
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/4/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>
@property (assign,nonatomic) NSString *userName;
@property (assign,nonatomic) NSString *marks;
@property (assign,nonatomic) NSString *win;
@property (assign,nonatomic) NSString *lost;
@property (assign,nonatomic) NSString *rates;
@property (strong,nonatomic) NSMutableDictionary *fightHistory;

- (instancetype)initWithUserName:(NSString *)name Marks:(NSString *)mark WinGames:(NSString *)wins LostGames:(NSString *)lost Rates:(NSString *)rates;
@end
