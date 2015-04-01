//
//  ContactTableViewController.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/11/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "ContactTableViewController.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "CustomTableViewCell.h"

@interface ContactTableViewController ()
@property (strong,nonatomic) AppDelegate *appDelegate;
@property (strong,nonatomic) DBManager *dbManager;

@end

@implementation ContactTableViewController{
  NSString *username;
  NSMutableArray *arrResults;
  NSMutableArray *arrUsername;
  NSArray *searchResults;
}

- (void)viewWillAppear:(BOOL)animated{
  if (self.dbManager && self.appDelegate) {
    username = [self.appDelegate.defaults objectForKey:@"displayName"];
    NSString *query=@"select * from contact";
    arrResults = [[NSMutableArray alloc] initWithArray:[self.dbManager loadDataFromDB:query] copyItems:YES];
    NSLog(@"%@",arrResults);
    NSLog(@"%@",query);
    [self.tableView reloadData];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  NSDictionary* navigationBarTitleAttributes =
  @{NSFontAttributeName:
      [UIFont fontWithName:@"Chalkduster" size:20.0f],
    NSForegroundColorAttributeName:
      [UIColor whiteColor]
    };
  
  NSDictionary* navigationRightBarButton =
  @{NSFontAttributeName:
      [UIFont fontWithName:@"Chalkduster" size:20.0f],
    NSForegroundColorAttributeName:
      [UIColor whiteColor]
    };
  self.navigationController.navigationBar.titleTextAttributes = navigationBarTitleAttributes;
 
  self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"db.sql"];
  //get contact Info
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - refresh table view data
- (IBAction)refreshTable:(id)sender{
  if (self.dbManager && self.appDelegate) {
    username = [self.appDelegate.defaults objectForKey:@"displayName"];
    NSString *query=[NSString stringWithFormat:@"select * from contact where username='%@'",username];
    arrResults = [[NSMutableArray alloc] initWithArray:[self.dbManager loadDataFromDB:query] copyItems:YES];
    NSLog(@"%@",arrResults);
    NSLog(@"%@",query);
    [self.tableView reloadData];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
  return arrResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *string = @"customCell";

  CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
    
    // Configure the cell...
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  
  if (arrResults.count > 0) {
      cell.nameLabel.text = [[arrResults objectAtIndex:indexPath.row] objectAtIndex:1];
      cell.marksLabel.text = [@"Marks :" stringByAppendingString:[[arrResults objectAtIndex:indexPath.row] objectAtIndex:2]];
      cell.winLabel.text = [@"Win :" stringByAppendingString:[[arrResults objectAtIndex:indexPath.row] objectAtIndex:3]];
      cell.loseLabel.text = [@"Lose :" stringByAppendingString:[[arrResults objectAtIndex:indexPath.row] objectAtIndex:4]];
      cell.ratesLabel.text = [@"Rates :%" stringByAppendingString:[[arrResults objectAtIndex:indexPath.row] objectAtIndex:5]];
    }

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 90;
}
@end
