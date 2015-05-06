// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

#import "AppDelegate.h"

#import "SavedDataManager.h"
#import "AccountManager.h"



static NSURL *sDocumentsDirectory;



@interface AppDelegate ()

@property (retain, nonatomic) SavedDataManager *savedDataMan;
@property (retain, nonatomic) AccountManager *accountMan;

@end



@implementation AppDelegate


/// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Preempt initialization of managers
	self.savedDataMan = SavedDataManager.sharedManager;
	self.accountMan = AccountManager.sharedManager;
	
	return YES;
}

/// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
/// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application
{
}

/// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
/// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

/// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

/// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

/// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application
{
}


#pragma Public Utils

- (NSURL *)documentsDirectory
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		sDocumentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
		[sDocumentsDirectory retain];
	});
	
	return sDocumentsDirectory;
}


@end
