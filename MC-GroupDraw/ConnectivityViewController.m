//
//  ConnectivityViewController.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 11/23/14.
//
@import MultipeerConnectivity;

#import "ConnectivityViewController.h"
#import "ViewController.h"
#import "SessionManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface ConnectivityViewController (){
  IBOutlet UILabel *userName;
  IBOutlet UISwitch *advertiserButton;
  IBOutlet UIButton *disconnectButton;
  IBOutlet UITableView *tableView;
  AppDelegate *appDelegate;
  NSString *displayName;
  NSString *serviceType;
  BOOL advertise;
  NSTimer *reloadTimer;
}

@end

@implementation ConnectivityViewController

#pragma mark MCBrowserViewControllerDelegate methods

- (BOOL) browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
  NSLog(@"shouldPresentNearbyPeer %@",peerID.displayName);
  return YES;
}

- (void) browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
  [browserViewController dismissViewControllerAnimated: YES completion: nil];
  [tableView reloadData];
}

- (void) browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
  [browserViewController dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark UITableViewDataSource methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.sessionMngr.session.connectedPeers.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"PeerCell"];
  MCPeerID * peerId = self.sessionMngr.session.connectedPeers[indexPath.row];
  cell.textLabel.text = peerId.displayName;
  return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  tableView.sectionIndexColor = [UIColor redColor];
  return @"Connected Peers";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
  // Set the text color of our header/footer text.
  UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
  [header.textLabel setTextColor:[UIColor whiteColor]];
  header.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0];

  // Set the background color of our header/footer.
  header.contentView.backgroundColor = [UIColor lightGrayColor];
}

- (void) reloadTable {
  NSLog(@"reloadTable");
  [tableView reloadData];
}

#pragma mark Controller methods

- (void) createSession {
  self.sessionMngr = [[SessionManager alloc] initWithDisplayName: displayName andServiceType: serviceType];
  self.sessionMngr.client = self.delegate;
}

- (IBAction)advertise:(UISwitch *)sender {
  [appDelegate.defaults setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"advertise"];
  
  if (sender.on) {
    NSLog(@"advertise on");
    if (!self.sessionMngr) [self createSession];
    [self.sessionMngr.advertiserAssistant start];
  }else {
    NSLog(@"advertise off");
  }
}

- (void)invitePeers:(id)sender{
  if (!self.sessionMngr) [self createSession];
  MCBrowserViewController * browserViewController = [[MCBrowserViewController alloc] initWithServiceType: serviceType session: self.sessionMngr.session];
  browserViewController.delegate = self;
  browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
  browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
  [self presentViewController: browserViewController animated: YES completion: nil];
}

- (IBAction)logOut:(id)sender{
  
  UINavigationController *loginVc = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
  [self presentViewController:loginVc animated:YES completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"View Did Load");
  self.view.backgroundColor = [UIColor whiteColor];
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  serviceType = [appDelegate.defaults objectForKey:@"serviceType"];
  displayName = [appDelegate.defaults objectForKey:@"displayName"];
  advertise = [[appDelegate.defaults objectForKey:@"advertise"] boolValue];
  
  //set userName table
  userName.text = displayName;
 
  //set switch status
  if (advertise == YES) {
    NSLog(@"ON");
  }else{
    advertiserButton.on = NO;
  }

  if ([advertiserButton isOn]) {
    [self.sessionMngr.advertiserAssistant start];
    NSLog(@"init start");
  }
  [tableView setDelegate:self];
  [tableView setDataSource:self];

  reloadTimer = [NSTimer timerWithTimeInterval: 1.0 target: self selector: @selector(reloadTable) userInfo: nil repeats: YES];
  [[NSRunLoop currentRunLoop] addTimer: reloadTimer forMode: NSDefaultRunLoopMode];

  // Do any additional setup after loading the view.
  NSArray *vc = ((UITabBarController *)self.navigationController.parentViewController).viewControllers;
  NSUInteger otherindex = 0;
  self.delegate = vc[otherindex];
  
  //custom navigator
    //right BarButton
  UIBarButtonItem *invitePeersButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self.navigationController.viewControllers[0] action:@selector(invitePeers:)];
  invitePeersButton.tintColor = [UIColor whiteColor];
  self.navigationItem.rightBarButtonItem = invitePeersButton;

    //custom title
  UILabel *lblTitle = [[UILabel alloc] init];
  lblTitle.text = @"Connectors";
  lblTitle.backgroundColor = [UIColor clearColor];
  lblTitle.textColor = [UIColor whiteColor];
  lblTitle.font = [UIFont fontWithName:@"Chalkduster" size:18.0];
  [lblTitle sizeToFit];
  self.navigationItem.titleView = lblTitle;
}

- (void) viewWillDisappear:(BOOL)animated{
  NSLog(@"View Will Disappear");
  NSLog(@"connected peers %lu" ,(unsigned long) self.sessionMngr.session.connectedPeers.count);
  [self.delegate connectivityControllerDidFinish:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
