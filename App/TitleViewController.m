// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

#import "TitleViewController.h"

@import Accounts;



#pragma mark - Constants

static NSString *const kAppName = @"Rustle";



#pragma mark - Helper Functions

NSUInteger innermostIndexOfIndexPath(NSIndexPath *indexPath)
{
	return [indexPath indexAtPosition:(indexPath.length - 1)];
}

NSException *exceptionForNilStoryboardIDProperty(id<NSObject> propertyOwner, const char *propertyName)
{
	return [NSException exceptionWithName:NSInvalidArgumentException
		reason:[NSString stringWithFormat:@"%@'s %s must be set to prior to using the object." @"\n"
				@"\t" @"You likely need to configure this in the storyboard under the %@'s User Defined Runtime Attributes.",
			propertyOwner, propertyName, propertyOwner.class
		]
		userInfo:nil
	];
}

NSException *exceptionForOutOfRangeInnermostIndexPath(NSIndexPath *indexPath, NSUInteger innermostIndex, const char *countVarName, NSUInteger countVarValue)
{
	return [NSException exceptionWithName:NSInvalidArgumentException
		reason:[NSString stringWithFormat:@"Invalid %@ has an innermost index of %lu, which must be < the %s (%lu).",
			indexPath, (unsigned long)innermostIndex, countVarName, (unsigned long)countVarValue
		]
		userInfo:nil
	];
}



#pragma mark - Class

@interface TitleViewController ()

@property(assign, nonatomic) UITableViewController *twitterTableController;
@property(retain, nonatomic) NSArray *twitterAccountsForPopover;

- (void)askForTwitterAcountFrom:(NSArray *)twitterAccounts;
- (void)initiateLoginWithAccount:(ACAccount *)twitterAccount;

- (void)presentTwitterAccessNotGrantedAlert;
- (void)presentNoTwitterAccountsAlert;
- (void)presentSettingsDirectingAlertWithTitle:(NSString *)title message:(NSString *)message;

@end



@implementation TitleViewController

@synthesize twitterPopoverSequeID=_twitterPopoverSequeID, twitterPopoverTableCellReuseID=_twitterPopoverTableCellReuseID;

- (NSString *)twitterPopoverSequeID
{
	if (_twitterPopoverSequeID == nil)
		@throw exceptionForNilStoryboardIDProperty(self, stringof(twitterPopoverSequeID));
	
	return [[_twitterPopoverSequeID retain] autorelease];
}

- (NSString *)twitterPopoverTableCellReuseID
{
	if (_twitterPopoverTableCellReuseID == nil)
		@throw exceptionForNilStoryboardIDProperty(self, stringof(twitterPopoverTableCellReuseID));
	
	return [[_twitterPopoverTableCellReuseID retain] autorelease];
}


#pragma UIViewController Aherence

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// @fillin: Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	// @fillin: Dispose of any resources that can be recreated.
}


#pragma mark Actions

- (IBAction)openTwitterLogin:(id)sender
{
	ACAccountStore *accountStore = [ACAccountStore new];
	ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	[accountStore requestAccessToAccountsWithType:twitterAccountType
		options:nil
		completion:^(BOOL granted, NSError *error) {
			if (!granted) {
				[self presentTwitterAccessNotGrantedAlert];
			}
			else {
				NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
				[self askForTwitterAcountFrom:twitterAccounts];
			}
		}
	];
}

- (void)askForTwitterAcountFrom:(NSArray *)twitterAccounts
{
	NSUInteger accountCount = twitterAccounts.count;
	
	if (accountCount == 0) {
		[self presentNoTwitterAccountsAlert];
	}
	else if (accountCount == 1) {
		[self initiateLoginWithAccount:twitterAccounts[0]];
	}
	else { // accountCount ≥ 2
		self.twitterAccountsForPopover = twitterAccounts; // for later use by `tableView:numberOfRowsInSection:`, `tableView:cellForRowAtIndexPath:`, `tableView:didSelectRowAtIndexPath:`
		
		[self performSegueWithIdentifier:self.twitterPopoverSequeID sender:self];
	}
}

- (void)initiateLoginWithAccount:(ACAccount *)twitterAccount
{
	NSLog(@"Using twitter account: %@", twitterAccount);
}


#pragma mark Alerts

- (void)presentTwitterAccessNotGrantedAlert {
	[self presentSettingsDirectingAlertWithTitle:@"Twitter Account Access Denied"
		message:[NSString stringWithFormat:@"%@ requires access to a Twitter account for indentification." @"\n\n"
			@"%@ does not use any information from Twitter other than your username, and %@ will no post anything to Twitter." @"\n\n"
			@"Please use the Settings app to allow Twitter accounts on this device.",
		kAppName, kAppName, kAppName
	]];
}

- (void)presentNoTwitterAccountsAlert {
	[self presentSettingsDirectingAlertWithTitle:@"No Twitter Accounts Found"
		message:@"No Twitter accounts are set up."  @"\n\n"
			@"Please use the Settings app to add a Twitter account."
	];
}

- (void)presentSettingsDirectingAlertWithTitle:(NSString *)title message:(NSString *)message
{
	UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	void(^doPresentAlert)() = ^{
		[self presentViewController:errorAlert animated:YES completion:nil];
	};
	
	[errorAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[errorAlert dismissViewControllerAnimated:YES completion:nil];
	}]];
	[errorAlert addAction:[UIAlertAction actionWithTitle:@"iOS Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}]];
	
	doPresentAlert();
}


#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:self.twitterPopoverSequeID]) {
		UITableViewController *destController = segue.destinationViewController;
		destController.tableView.dataSource = self;
		destController.tableView.delegate = self;
		self.twitterTableController = destController;
	}
}


#pragma mark Twitter-Popover UITableViewDataSource & UITableViewDelegate Responsibilities

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!tableView)
		return 0;
	
	if (tableView == self.twitterTableController.tableView)
	{
		switch (section) {
			case 0:
				return self.twitterAccountsForPopover.count;
			
			default:
				return 0;
		}
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!tableView)
		return nil;
	
	if (tableView == self.twitterTableController.tableView)
	{
		NSArray *twitterAccounts = self.twitterAccountsForPopover;
		
		NSUInteger innermostIndex = innermostIndexOfIndexPath(indexPath);
		if (innermostIndex >= twitterAccounts.count)
			@throw exceptionForOutOfRangeInnermostIndexPath(indexPath, innermostIndex, stringof(twitterAccounts.count), twitterAccounts.count);
		
		ACAccount *twitterAccount = twitterAccounts[innermostIndex];
		UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:self.twitterPopoverTableCellReuseID];
		tableCell.textLabel.text = twitterAccount.accountDescription;
		
		return tableCell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!tableView)
		return;
	
	if (tableView == self.twitterTableController.tableView)
	{
		NSArray *twitterAccounts = self.twitterAccountsForPopover;
		
		NSUInteger innermostIndex = innermostIndexOfIndexPath(indexPath);
		if (innermostIndex >= twitterAccounts.count)
			@throw exceptionForOutOfRangeInnermostIndexPath(indexPath, innermostIndex, stringof(twitterAccounts.count), twitterAccounts.count);
		
		ACAccount *twitterAccount = twitterAccounts[innermostIndex];
		
		[self.twitterTableController dismissViewControllerAnimated:YES completion:nil];
		self.twitterTableController = nil;
		
		[self initiateLoginWithAccount:twitterAccount];
	}
}

@end
