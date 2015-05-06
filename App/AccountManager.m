// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

#import "AccountManager.h"



static AccountManager *sSharedManager = nil;



@interface AccountManager () {
	BOOL _authenticated;
}
@end



@implementation AccountManager


#pragma mark Lifecycle

+ (instancetype)sharedManager
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		sSharedManager = [AccountManager new];
	});
	
	return sSharedManager;
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_authenticated = NO;
	
	return self;
}


#pragma mark Authentication

- (BOOL)isAuthenticated {
	return _authenticated;
}

- (BOOL)authenticateUsingTwitterAccount:(ACAccount *)twitterAccount
{
	if (self.authenticated) {
		NSLog(
			@"Error: %@ is already authenticated." @"\n"
				@"\t" "If trying to change the authentication, you need to deauthenticate first.",
			self
		);
		return NO;
	}
	
	BOOL isTwitterType = [twitterAccount.accountType.identifier isEqualToString:ACAccountTypeIdentifierTwitter];
	if (!isTwitterType)
		@throw [NSException exceptionWithName:NSInvalidArgumentException
			reason:[NSString stringWithFormat:@"Invalid %s %@.  The account must be a Twitter account.",
				stringof(twitterAccount), twitterAccount
			]
			userInfo:nil];
	
	// @todo: set up ivars using `twitterAccount`
	
	return YES;
}


@end
