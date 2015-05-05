// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

#import "TitleViewController.h"

@import Accounts;



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

@property(assign, nonatomic) UITableViewController *twitterPopoverController;
@property(retain, nonatomic) NSArray *twitterAccounts;

- (void)askForTwitterAcountFrom:(NSArray *)twitterAccounts;
- (void)initiateLoginWithAccount:(ACAccount *)twitterAccount;

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
			if (!granted)
				return;
			
			NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
			[self askForTwitterAcountFrom:twitterAccounts];
		}
	];
}

- (void)askForTwitterAcountFrom:(NSArray *)twitterAccounts
{
	NSUInteger accountCount = twitterAccounts.count;
	
	if (accountCount == 0) {
		UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"No Twitter Accounts"
			message:@"No Twitter accounts are set up.  Go to the Settings and git'r'done!"
			preferredStyle:UIAlertControllerStyleAlert];
		
		void(^doPresentAlert)() = ^{
			[self presentViewController:errorAlert animated:YES completion:nil];
		};
		
		[errorAlert addAction:[UIAlertAction actionWithTitle:@"Will Do" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[errorAlert dismissViewControllerAnimated:YES completion:nil];
		}]];
		
		doPresentAlert();
	}
	else if	(accountCount == 1) {
		[self initiateLoginWithAccount:self.twitterAccounts[0]];
	}
	else {
		self.twitterAccounts = twitterAccounts; // for later use by `tableView:numberOfRowsInSection:`, `tableView:cellForRowAtIndexPath:`, `tableView:didSelectRowAtIndexPath:`
		
		[self performSegueWithIdentifier:self.twitterPopoverSequeID sender:self];
	}
}

- (void)initiateLoginWithAccount:(ACAccount *)twitterAccount
{
	NSLog(@"Using twitter account: %@", twitterAccount);
}


#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:self.twitterPopoverSequeID]) {
		UITableViewController *destController = segue.destinationViewController;
		destController.tableView.dataSource = self;
		destController.tableView.delegate = self;
		self.twitterPopoverController = destController;
	}
}


#pragma mark Twitter-Popover UITableViewDataSource & UITableViewDelegate Responsibilities

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!tableView)
		return 0;
	
	if (tableView == self.twitterPopoverController.tableView)
	{
		switch (section) {
			case 0:
				return self.twitterAccounts.count;
			
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
	
	if (tableView == self.twitterPopoverController.tableView)
	{
		NSArray *twitterAccounts = self.twitterAccounts;
		
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
	
	if (tableView == self.twitterPopoverController.tableView)
	{
		NSArray *twitterAccounts = self.twitterAccounts;
		
		NSUInteger innermostIndex = innermostIndexOfIndexPath(indexPath);
		if (innermostIndex >= twitterAccounts.count)
			@throw exceptionForOutOfRangeInnermostIndexPath(indexPath, innermostIndex, stringof(twitterAccounts.count), twitterAccounts.count);
		
		ACAccount *twitterAccount = twitterAccounts[innermostIndex];
		
		[self.twitterPopoverController dismissViewControllerAnimated:YES completion:nil];
		self.twitterPopoverController = nil;
		
		[self initiateLoginWithAccount:twitterAccount];
	}
}

@end
