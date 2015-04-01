//
//  RegisterViewController.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/8/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "RegisterViewController.h"
#import "DBManager.h"

@interface RegisterViewController ()

@property (strong,nonatomic) IBOutlet UITextField *usernameField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) NSArray *arrResult;


- (IBAction)registerInfo:(id)sender;
@end

@implementation RegisterViewController

#pragma mark - textField methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - registerInfo method

- (IBAction)registerInfo:(id)sender{
  if (self.usernameField.text && self.passwordField.text)
  {
    NSString *query = [NSString stringWithFormat:@"select * from localInfo where username='%@'",self.usernameField.text];
    self.arrResult = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (self.arrResult.count == 0)
    {
      NSString *insertQuery = [NSString stringWithFormat:@"Insert into localInfo values('%@','%@',%d,%d,%d,%f)",self.usernameField.text,self.passwordField.text,0,0,0,0.0];
      
      [self.dbManager executeQuery:insertQuery];
      
      if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was successfully, affected rows are %d",self.dbManager.affectedRows);
        
        //Pop the view controller
        [self.navigationController popViewControllerAnimated:YES];
      }else{
        NSLog(@"Query not successfully");
      }
    }
  }else{
    NSLog(@"Please Enter information");
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  //set textField delegate
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
  
  self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"db.sql"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
