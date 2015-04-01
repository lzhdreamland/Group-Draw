//
//  DBManager.h
//  SqliteTest
//
//  Created by ZihaoLin on 12/7/14.
//  Copyright (c) 2014 ZihaoLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (strong,nonatomic) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
- (NSArray *)loadDataFromDB:(NSString *)query;
- (void)executeQuery:(NSString *)query;

@end
