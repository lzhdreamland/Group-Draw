//
//  ViewController.m
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/7/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"
#import "ConnectivityViewController.h"
#import "SessionManager.h"
#import "DrawView.h"
#import "Curve.h"
#import "Clocker.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "User.h"

@interface ViewController () <SettingsDelegateProtocol, SessionClientProtocol ,ConnectivityDelegateProtocol>
@property (strong,nonatomic) NSMutableDictionary * settings;
@property (strong,nonatomic) NSMutableDictionary * drawerInfo;
@property (strong,nonatomic) SessionManager * sessionMngr;
@property (strong,nonatomic) DBManager *dbManager;
@property (strong,nonatomic) AppDelegate *appDelegate;
@property (strong,nonatomic) UIView *answerView;
@property (strong,nonatomic) UIView *guessingView;
@property (weak,nonatomic) IBOutlet DrawView * drawView;
@property (strong,nonatomic) IBOutlet UITextField *answerField;
@property (strong,nonatomic) IBOutlet UITextField *hint1Field;
@property (strong,nonatomic) IBOutlet UITextField *hint2Field;
@property (strong,nonatomic) IBOutlet UITextField *guessAnswer;
@property (strong,nonatomic) IBOutlet UISegmentedControl *roleSelected;
@property (strong,nonatomic) IBOutlet UILabel *guessDisplayHint1;
@property (strong,nonatomic) IBOutlet UILabel *guessDisplayHint2;
@end

@implementation ViewController
{
  BOOL DrawOrGuess;
  BOOL clear;
  BOOL beginDraw;
  BOOL figureOut;
  int marks;
  int wingames;
  int lostgames;
  int guessCount;
  int totalGuessCount;
  NSString *answerText;
  NSString *guessAnswerText;
  NSString *hint1Text;
  NSString *hint2Text;
  NSString *answer;
  NSString *userName;
  UIButton *actionButton;
  NSTimer *reloadTimer;
  Clocker *timeCalculator;
}

#pragma mark Action Methods for Slide up View

- (IBAction)getAnswer:(UITextField *)sender{
  answerText = sender.text;
}

- (IBAction)getGuessAnswer:(UITextField *)sender {
  guessAnswerText = sender.text;
}

- (IBAction)getHint1:(UITextField *)sender{
  hint1Text = sender.text;
}

- (IBAction)getHint2:(UITextField *)sender{
  hint2Text = sender.text;
}

- (IBAction)submitDrawInfo:(UIButton *)sender{
  if (answerText && hint1Text && hint2Text) {
    [self.drawerInfo setObject:answerText forKey:@"answer"];
    [self.drawerInfo setObject:hint1Text forKey:@"hint1"];
    [self.drawerInfo setObject:hint2Text forKey:@"hint2"];
   
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    if (!self.sessionMngr.hasPeers) return;
    NSLog(@"hasPeers?");
    [archiver encodeObject:self.drawerInfo forKey:@"drawerInfo"];
    [archiver finishEncoding];
    [self.sessionMngr sendData: data];
    NSLog(@"%@" , self.drawerInfo);
    [self.answerView removeFromSuperview];
    self.answerView = nil;
    [self.drawView setNeedsDisplay];
    //be able to begin draw
    beginDraw = YES;
    
    //create timer for drawing (60s)
    [self showTimeCalculatorWithTimeLimit:[NSNumber numberWithInt:60]];
  }
}

- (IBAction)submitGuessAnswer:(UIButton *)sender {
  if (totalGuessCount == 0) return;
  
  if ([guessAnswerText isEqualToString:answer]) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Con!!!" message:@"You got it!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    figureOut = YES;
    
    //calculate marks and update database
    [self calculateMarks:[NSNumber numberWithInt:timeCalculator.initTime]];
    
    //remove guess view
    [self.guessingView removeFromSuperview];
    [self.drawView setNeedsDisplay];
    self.guessingView = nil;
    [timeCalculator removeFromSuperview];
    timeCalculator = nil;
    [self performSelectorOnMainThread:@selector(cancelSelected:) withObject:self.roleSelected waitUntilDone:NO];
    
    //transmit consequence back to 'drawer' side
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    if (!self.sessionMngr.hasPeers) return;
    NSLog(@"hasPeers?");
    [archiver encodeObject:[NSNumber numberWithBool:figureOut] forKey:@"figureout"];
    [archiver finishEncoding];
    [self.sessionMngr sendData: data];
    
    //clear screen
    [self clearDrawView];
  }else{
    totalGuessCount--;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!!!" message:[NSString stringWithFormat:@"Sorry! You have %d chance(s) left",totalGuessCount] delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
    [alertView show];
    
    if (totalGuessCount == 0) {
      //remove guessingView
      [self.guessingView removeFromSuperview];
      [self.drawView setNeedsDisplay];
      self.guessingView = nil;
      //calculate marks and update database
      [self calculateMarks:[NSNumber numberWithInt:timeCalculator.initTime]];
      
      [timeCalculator removeFromSuperview];
      timeCalculator = nil;
      [self performSelectorOnMainThread:@selector(cancelSelected:) withObject:self.roleSelected waitUntilDone:NO];
      
      //transmit consequence back to 'drawer' side
      NSMutableData *data = [NSMutableData data];
      NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
      if (!self.sessionMngr.hasPeers) return;
      NSLog(@"hasPeers?");
      [archiver encodeObject:[NSNumber numberWithBool:figureOut] forKey:@"figureout"];
      [archiver finishEncoding];
      [self.sessionMngr sendData: data];
      
      //clear screen
      [self clearDrawView];
    }
  }
  
}

- (void) calculateMarks : (NSNumber *) leftTime{
  int left = [leftTime intValue];
  NSLog(@"left time is %d" ,left);
  
  if (DrawOrGuess && !figureOut)
  {
    marks = 1;
    wingames = 1;
    lostgames = 0;
  }else if (DrawOrGuess && figureOut){
    marks = 0;
    lostgames = 1;
    wingames = 0;
  }else if (!DrawOrGuess && figureOut ){
    wingames = 1;
    lostgames = 0;
    switch (left/30) {
      case 0:
        marks = 1;
        break;
      case 1:
        marks = 2;
        break;
      case 2:
        marks = 3;
        break;
    }
  }else if (!DrawOrGuess && !figureOut){
    marks = 0;
    wingames = 0;
    lostgames = 1;
  }
  
  NSString *queryMarks = [NSString stringWithFormat:@"select * from localInfo where username='%@'",userName];
  NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:queryMarks]];
  NSString * previousMarks =[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"marks"]];
  NSString * previousWin = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"wingames"]];
  NSString * previousLost = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"lostgames"]];

  marks = marks+[previousMarks intValue];
  wingames += [previousWin intValue];
  lostgames += [previousLost intValue];
  double rates =round(100 * (double)wingames/(wingames + lostgames)) ;
  
  NSLog(@"consequences are %d , %d , %d , %f", marks,wingames,lostgames,rates);
  
  NSString *updateQuery = [NSString stringWithFormat:@"update localInfo set marks=%d,wingames=%d,lostgames=%d,rate=%f where username='%@'",marks,wingames,lostgames,rates,userName];
  [self.dbManager executeQuery:updateQuery];
  results = [self.dbManager loadDataFromDB:queryMarks];
  NSLog(@"updatedMarks is %@", results);
  
  //send userInfo
  NSString *query = [NSString stringWithFormat:@"select * from localInfo where username='%@'",userName];
  NSArray *arrResults = [self.dbManager loadDataFromDB:query];
  NSString *Marks = [[arrResults objectAtIndex:0] objectAtIndex:2];
  NSString *winsGames = [[arrResults objectAtIndex:0] objectAtIndex:3];
  NSString *lostGames = [[arrResults objectAtIndex:0] objectAtIndex:4];
  NSString *Rates = [[arrResults objectAtIndex:0] objectAtIndex:5];
  NSLog(@"%@",query);
  NSLog(@"%@",arrResults);
  
  User *drawUser = [[User alloc] init];
  drawUser.userName = userName;
  drawUser.marks = Marks;
  drawUser.win = winsGames;
  drawUser.lost = lostGames;
  drawUser.rates = Rates;
  NSMutableData *dataUser = [NSMutableData data];
  NSKeyedArchiver *archiverUser = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataUser];
  if(!self.sessionMngr.hasPeers) return;
  [archiverUser encodeObject:drawUser forKey:@"userInfo"];
  [archiverUser finishEncoding];
  [self.sessionMngr sendData:dataUser];
}

- (IBAction)selectRole:(UISegmentedControl *)sender {
  switch (self.roleSelected.selectedSegmentIndex) {
    case 0:
    {
      DrawOrGuess=YES;
      beginDraw = NO;
      NSLog(@"U choosed answer!!!");
    }
      break;
    case 1:
    {
      DrawOrGuess=NO;
      beginDraw = NO;
      NSLog(@"U choosed guess!!!");
    }
  }
  [self showButton];
  
  //send identity 'Drawer' or 'Guesser'
    //encapsulated into nskeyedarchiver
  NSMutableData *data = [NSMutableData data];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject:[NSNumber numberWithBool:DrawOrGuess] forKey:@"identity"];
  [archiver finishEncoding];
    //send encapsulated data
  [self.sessionMngr sendData:data];
  NSLog(@"identity send successfully!!!!!");
}

- (IBAction)clearCurve:(UIButton *)sender {
  if (self.drawView) {
    clear = YES;
    [self clearDrawView];
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:[NSNumber numberWithBool:clear] forKey:@"clear"];
    [archiver finishEncoding];
    [self.sessionMngr sendData:data];
  }
}

- (IBAction)hideAnswerView:(UIButton *)sender {
  if (self.guessingView)
  {
    [UIView animateWithDuration: 0.2 animations: ^(void) {self.guessingView.frame = CGRectOffset(self.guessingView.frame,0,self.guessingView.frame.size.height); } ];
  }else if (self.answerView)
  {
    [UIView animateWithDuration: 0.2 animations: ^(void) {self.answerView.frame = CGRectOffset(self.answerView.frame,0,self.answerView.frame.size.height); } ];
  }
 }


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
  if (textField == _answerField || textField == _hint1Field || textField == _hint2Field || textField == _guessAnswer)
  {
    [textField resignFirstResponder];
    return NO;
  }
  return YES;
}

#pragma mark Touch Event Methods
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  //cannot draw if with 'guess' identity
  if (DrawOrGuess == NO) return;
  
  //cannot draw before submit answer firstly;
  if (beginDraw == NO) return;
    
  UITouch * touch = [[event touchesForView: self.drawView] anyObject];
  CGPoint pt = [touch locationInView: self.drawView];
  
  UIBezierPath * path = [UIBezierPath bezierPath];
  path.lineWidth = ((NSNumber *)self.settings[@"strokeWidth"]).doubleValue;
  [path moveToPoint: pt];
  
  Curve * curve = [[Curve alloc] init];
  curve.path = path;
  curve.color = self.settings[@"strokeColor"];
  self.drawView.currentCurve = curve;
  [self.drawView setNeedsDisplay];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  //cannot draw if with 'guess' identity
  if (DrawOrGuess == NO) return;
  
  //cannot draw before submit answer firstly;
  if (beginDraw == NO) return;
  
  UITouch * touch = [[event touchesForView: self.drawView] anyObject];
  CGPoint pt = [touch locationInView: self.drawView];
  
  [self.drawView.currentCurve.path addLineToPoint: pt];
  [self.drawView setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  //cannot draw if with 'guess' identity
  if (DrawOrGuess == NO) return;
  
  //cannot draw before submit answer firstly;
  if (beginDraw == NO) return;
  
  NSLog(@"touchesEnded");
  UITouch * touch = [[event touchesForView: self.drawView] anyObject];
  CGPoint pt = [touch locationInView: self.drawView];
  [self.drawView.currentCurve.path addLineToPoint: pt];
  [self.drawView setNeedsDisplay];
  
  [self addCurve: self.drawView.currentCurve];
  NSLog(@"hasPeers?");
  if (!self.sessionMngr.hasPeers) return;
  NSLog(@"hasPeers");
  NSMutableData * data = [NSMutableData data];
  NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject: self.drawView.currentCurve forKey: @"curve"];
  [archiver finishEncoding];
  NSLog(@"finishEncoding");
  [self.sessionMngr sendData: data];
}

#pragma mark SessionClientProtocol methods
//add curve on draw view
- (void) addCurve: (Curve *) curve {
  [self.drawView.curveList addObject: curve];
  [self.drawView setNeedsDisplay];
}

//clear draw view
- (void) clearDrawView{
  if (clear == YES) {
    [self.drawView.curveList removeAllObjects];
    self.drawView.currentCurve = nil;
    [self.drawView setNeedsDisplay];
  }
}

//reset UISegmentedControl 'roleSelected'
- (void) cancelSelected : (UISegmentedControl *)segment{
  [segment setSelectedSegmentIndex:UISegmentedControlNoSegment];
  [segment setNeedsDisplay];
}

//set UISegmentedControl 'roleSelected'
- (void) setSelected{
  DrawOrGuess ? (_roleSelected.selectedSegmentIndex = 0) : (_roleSelected.selectedSegmentIndex = 1);
}

//update timeCalculator
- (void)calculateTime{
  if (timeCalculator) {
    if (timeCalculator.initTime > 0)
    {
      timeCalculator.initTime--;
      [timeCalculator setNeedsDisplay];
      [timeCalculator update];
    }else{
      if (DrawOrGuess == YES) {
        beginDraw = NO;
        [timeCalculator removeFromSuperview];
        timeCalculator = nil;
      }
    }
  }
}

//display AnswerView for drawer
- (void) showAnswerView{
  if (!self.answerView) {
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"AnswerView" owner:self options:nil];
    self.answerView = views[0];
    CGRect viewsBds = self.answerView.bounds;
    CGRect screenBds = [[UIScreen mainScreen] bounds];
    self.answerView.frame = CGRectMake(screenBds.origin.x, screenBds.origin.y+screenBds.size.height/3+100, screenBds.size.width, viewsBds.size.height);
    [self.view addSubview:self.answerView];
    actionButton.hidden = YES;
    [self.drawView setNeedsDisplay];
  }
  [UIView animateWithDuration: 0.2 animations: ^(void){self.answerView.frame = CGRectOffset(self.answerView.frame,0,-self.answerView.frame.size.height); } ];
}

//display GuessView for guesser
- (void) showGuessView{
  if (!self.guessingView) {
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"GuessView" owner:self options:nil];
    self.guessingView = views[0];
    CGRect viewsBds = self.guessingView.bounds;
    CGRect screenBds = [[UIScreen mainScreen] bounds];
    self.guessingView.frame = CGRectMake(screenBds.origin.x, screenBds.origin.y+screenBds.size.height-self.tabBarController.tabBar.frame.size.height, screenBds.size.width, viewsBds.size.height);
    [self.view addSubview:self.guessingView];
    totalGuessCount = 3;
    //set up Timer to update hints Label
    reloadTimer = [NSTimer timerWithTimeInterval: 1.0 target: self selector: @selector(reloadHintsLabel) userInfo: nil repeats: YES];
    [[NSRunLoop currentRunLoop] addTimer: reloadTimer forMode: NSDefaultRunLoopMode];

  }
  [UIView animateWithDuration:0.2 animations:^(void){self.guessingView.frame = CGRectOffset(self.guessingView.frame, 0, -self.guessingView.frame.size.height);}];
}

//display button for different views (answerView || guessView) respectivily
- (void) showButton{
  if (DrawOrGuess) {
    [actionButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [actionButton addTarget:self action:@selector(showAnswerView) forControlEvents:UIControlEventTouchUpInside];
    [actionButton setTitle:@"Begin" forState:UIControlStateNormal];
    actionButton.hidden = NO;
  }else{
    [actionButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [actionButton addTarget:self action:@selector(showGuessView) forControlEvents:UIControlEventTouchUpInside];
    [actionButton setTitle:@"Guess" forState:UIControlStateNormal];
    actionButton.hidden = NO;
  }
}

- (void) showTimeCalculatorWithTimeLimit:(NSNumber *) timeLimit{
  //init time calculator
  NSArray * nib = [[NSBundle mainBundle] loadNibNamed: @"Clocker" owner: self options: nil];
  timeCalculator = nib[0];
  CGRect rect = CGRectInset(CGRectMake(100,100,0,0),-50,-50);
  timeCalculator.frame = rect;
  timeCalculator.initTime = [timeLimit intValue];
  [self.view addSubview:timeCalculator];
  
  NSTimer *timeCalculation = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(calculateTime) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:timeCalculation forMode:NSDefaultRunLoopMode];
}

//refresh 'guessView' after receiving data of answers
- (void) reloadHintsLabel{
  if (!self.guessingView) return;
  NSLog(@"reload hints label");
  [self.guessDisplayHint1 setNeedsDisplay];
  [self.guessDisplayHint2 setNeedsDisplay];
}

// since this is invoked by the MCSession on receiving data it will occur on a separate thread
// so need to actually add curve and setNeedsDisplay on main thread
- (void) processData: (NSData *) data fromPeer:(MCPeerID *)peer {
  NSLog(@"processData");
  NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
  
  //derive data for answers and hints
  if ([unarchiver decodeObjectForKey:@"drawerInfo"]){
    NSLog(@"arrived txt data");
    NSMutableDictionary *answerAndHints = [unarchiver decodeObjectForKey:@"drawerInfo"];
    NSString *derivedAnswer = [answerAndHints objectForKey:@"answer"];
    NSString *hint1 = [answerAndHints objectForKey:@"hint1"];
    NSString *hint2 = [answerAndHints objectForKey:@"hint2"];
    if (DrawOrGuess == NO)
    {
      figureOut = NO;
      self.guessDisplayHint1.text = hint1;
      self.guessDisplayHint2.text = hint2;
      answer = derivedAnswer;
      [self performSelectorOnMainThread:@selector(showTimeCalculatorWithTimeLimit:) withObject:[NSNumber numberWithInt:90] waitUntilDone:NO];
    }
    NSLog(@"%@, %@, %@", answer, hint1, hint2);
  }
  
  //derive data for drawing
  if ([unarchiver decodeObjectForKey:@"curve"]) {
    NSLog(@"arrived drawing data");
    Curve * curve = [unarchiver decodeObjectForKey: @"curve"];
    [self performSelectorOnMainThread: @selector(addCurve:) withObject: curve waitUntilDone: NO];
  }
  
  //derive data for player identity
  if ([unarchiver decodeObjectForKey:@"identity"]) {
    NSLog(@"arrived other's identity");
    DrawOrGuess = ![[unarchiver decodeObjectForKey:@"identity"] boolValue];
    NSLog(DrawOrGuess ? @"Draw" : @"Guess");
    //guesser can guess 3 times
    if (!DrawOrGuess) {
      totalGuessCount = 3;
      NSLog(@"Guessing time left %d", totalGuessCount);
    }
    [self performSelectorOnMainThread:@selector(setSelected) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(showButton) withObject:nil waitUntilDone:NO];
  }
  
  //derive 'figureout' [NSNumber numberWithbool:figureout] to get marks
  if ([unarchiver decodeObjectForKey:@"figureout"]) {
    NSLog(@"figure Out");
    figureOut = [[unarchiver decodeObjectForKey:@"figureout"] boolValue];
    [self performSelectorOnMainThread:@selector(calculateMarks:) withObject:[NSNumber numberWithInt:timeCalculator.initTime] waitUntilDone:NO];
    
    //reset for replaying
    //1.clear 'drawView'
    clear = YES;
    [self performSelectorOnMainThread:@selector(clearDrawView) withObject:nil waitUntilDone:NO];
    //2.clear 'timeCalculator'
    [timeCalculator removeFromSuperview];
    timeCalculator = nil;
    //3.cancel
    [self performSelectorOnMainThread:@selector(cancelSelected:) withObject:self.roleSelected waitUntilDone:NO];
    //4.reset
  }
  
  //derive 'clear' command
  if ([unarchiver decodeObjectForKey:@"clear"]) {
    clear = [[unarchiver decodeObjectForKey:@"clear"] boolValue];
    [self performSelectorOnMainThread:@selector(clearDrawView) withObject:nil waitUntilDone:NO];
  }
  
  //derive 'userInfo' for contact
  if ([unarchiver decodeObjectForKey:@"userInfo"]) {
    NSLog(@"userInfo");
    User *userInfo = [unarchiver decodeObjectForKey:@"userInfo"];
    NSString *preQuery = [NSString stringWithFormat:@"select * from contact where othername='%@'",userInfo.userName];
    if ([[self.dbManager loadDataFromDB:preQuery] count] == 0)
    {
      NSString *query = [NSString stringWithFormat:@"insert into contact values('%@','%@',%d,%d,%d,%f)",userName,userInfo.userName,[userInfo.marks intValue],[userInfo.win intValue],[userInfo.lost intValue],[userInfo.rates doubleValue]];
      [self.dbManager executeQuery:query];
      NSLog(@"%@",query);
    }else{
      NSString *updateQuery = [NSString stringWithFormat:@"update contact set marks=%d,wingames=%d,lostgames=%d,rate=%f where othername='%@'",[userInfo.marks intValue],[userInfo.win intValue],[userInfo.lost intValue],[userInfo.rates doubleValue],userInfo.userName];
      [self.dbManager executeQuery:updateQuery];
      NSLog(@"%@",updateQuery);
      NSLog(@"%@",[self.dbManager loadDataFromDB:preQuery]);
    }
  }
  
  [unarchiver finishDecoding];
  NSLog(@"processData end");
}

#pragma mark SettingDelegateProtocol methods

- (void) settingsControllerDidFinish: (SettingsViewController *) sender {
  [self dismissViewControllerAnimated: YES completion: nil];
  //[self.sessionMngr sendData: [@"Some Data" dataUsingEncoding: NSASCIIStringEncoding]];
}

#pragma mark ConnectivityDelegateProtocol methods

- (void) connectivityControllerDidFinish: (ConnectivityViewController *) sender{
  NSLog(@"Connectivity Protocol");
  if (sender.sessionMngr) self.sessionMngr = sender.sessionMngr;
  NSLog(@"connected peers are %lu", (unsigned long)self.sessionMngr.session.connectedPeers.count);
}


#pragma mark ViewController methods 

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if (![segue.identifier isEqualToString: @"SettingsSegue"]) return;
  SettingsViewController * settingsCtlr = segue.destinationViewController;
  settingsCtlr.delegate = self;
  settingsCtlr.settings = self.settings;
//  settingsCtlr.sessionMngr = self.sessionMngr;
}

- (void) viewDidAppear:(BOOL)animated{
  NSLog(@"View Did Appear");
  //init full marks
  marks = 90;
  [self.drawerInfo removeAllObjects];
 
}

- (void) viewDidLoad {
  [super viewDidLoad];
  NSLog(@"View Did Load");
  //Get 'username' via AppDelegate userdefaults
  self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  userName = [self.appDelegate.defaults objectForKey:@"displayName"];
  NSLog(@"Welcome! %@ .",userName);
  
  //Access to database
  self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"db.sql"];
   
  self.settings = [[NSMutableDictionary alloc] initWithCapacity: 10];
  self.drawerInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
  [self.settings setObject: [UIColor blackColor] forKey: @"strokeColor"];
  [self.settings setObject: [NSNumber numberWithDouble: 1.0] forKey: @"strokeWidth"];
  [self.settings setObject: @"GroupDraw" forKey: @"serviceType"];
  [self.settings setObject: [[UIDevice currentDevice] name] forKey: @"displayName"];
  self.drawView.curveList = [NSMutableArray arrayWithCapacity: 10];
  
  //init an UIButton
  actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  actionButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height-self.tabBarController.tabBar.frame.size.height-35, 50, 30);
  actionButton.hidden = YES;
  actionButton.backgroundColor = [UIColor clearColor];
  actionButton.tintColor = [UIColor lightGrayColor];
  [self.drawView addSubview:actionButton];
  
  //set tabBar style
  [self.tabBarController.tabBar setTintColor:[UIColor redColor]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
