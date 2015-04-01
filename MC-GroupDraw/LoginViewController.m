//
//  LoginViewController.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/8/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "LoginViewController.h"
#import "DBManager.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (strong,nonatomic) IBOutlet UITextField *userNameField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) IBOutlet UIBarButtonItem *registerButton;
@property (strong,nonatomic) IBOutlet UIButton *signIn;
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) AppDelegate *appDelegate;
@property (strong,nonatomic) NSArray *arrResults;

- (IBAction)registerNewPlayer:(id)sender;
- (IBAction)signIn:(id)sender;
@end

@implementation LoginViewController{
  NSString *username;
  NSString *password;
  BOOL userExist;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}

- (IBAction)registerNewPlayer:(id)sender{
  [self performSegueWithIdentifier:@"register" sender:self];
}

- (IBAction)signIn:(id)sender{
  if (self.userNameField.text && self.passwordField.text) {
    NSString *query = [NSString stringWithFormat:@"select * from localInfo where username='%@'",self.userNameField.text];
    self.arrResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if (self.arrResults.count != 0)
    {
      if ([[[self.arrResults objectAtIndex:0] objectAtIndex:1] isEqualToString:self.passwordField.text])
      {
        userExist = YES;
        [self.appDelegate.defaults setObject:self.userNameField.text forKey:@"displayName"];
        [self.appDelegate.defaults synchronize];
        [self performSegueWithIdentifier:@"MainView" sender:self];
      }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong" message:@"Password doesn't match" delegate:self cancelButtonTitle:@"Re-try" otherButtonTitles:nil, nil];
        [alertView show];
        self.passwordField.text = nil;
      }
    }else{
      userExist = NO;
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong" message:@"Username doesn't match" delegate:self cancelButtonTitle:@"Re-try" otherButtonTitles:nil, nil];
      [alertView show];
      self.userNameField.text = nil;
      self.passwordField.text = nil;
      NSLog(@"username not existed");
    }
  }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
  if (userExist == NO) {
    return NO;
  }else {
    return YES;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.userNameField.delegate = self;
  self.passwordField.delegate = self;
  //init appDelegate to transmit value username
  self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

  //textTitleattributes dictionary for rightBarButtonItem && navigationBar
  NSDictionary* barButtonItemAttributes =
  @{NSFontAttributeName:
      [UIFont fontWithName:@"Chalkduster" size:15.0f],
    NSForegroundColorAttributeName:
      [UIColor lightGrayColor]
    };
  NSDictionary* navigationBarTitleAttributes =
  @{NSFontAttributeName:
      [UIFont fontWithName:@"Chalkduster" size:20.0f],
    NSForegroundColorAttributeName:
      [UIColor whiteColor]
    };

  [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
  [self.navigationController.navigationBar setTitleTextAttributes:navigationBarTitleAttributes];
  
   //init DBManager for accessing database
  self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"db.sql"];
  
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
