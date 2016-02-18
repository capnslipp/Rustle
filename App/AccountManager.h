// Rustle
// @author: Slipp Douglas Thompson

@import Foundation;
@import Accounts;



@interface AccountManager : NSObject

+ (instancetype)sharedManager;

@property(assign, readonly, getter=isAuthenticated, nonatomic) BOOL authenticated;

- (BOOL)authenticateUsingTwitterAccount:(ACAccount *)twitterAccount;

@end
