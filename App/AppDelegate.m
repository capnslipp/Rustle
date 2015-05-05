// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

#import "AppDelegate.h"



NSString *const kCoreDataSQLiteExtensionlessFileame = @"GTCoreBluetoothDemo";

NSArray *const kMainBundlePlaceholder = nil;



@interface AppDelegate ()

@property(assign, readonly, nonatomic) BOOL hasManagedObjectContext;

@end



@implementation AppDelegate


/// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
	[self saveContext];
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
	[self saveContext];
}


#pragma mark Core Data Stack

@synthesize applicationDocumentsDirectory=_applicationDocumentsDirectory;
@synthesize managedObjectModel=_managedObjectModel, persistentStoreCoordinator=_persistentStoreCoordinator, managedObjectContext=_managedObjectContext;

/// The directory the application uses to store the Core Data store file. This code uses a directory named the same as the CFBundleIdentifier within the application's documents directory.
- (NSURL *)applicationDocumentsDirectory
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		_applicationDocumentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
		[_applicationDocumentsDirectory retain];
	});
	
	return _applicationDocumentsDirectory;
}

/// The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
- (NSManagedObjectModel *)managedObjectModel
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:kMainBundlePlaceholder];
		[_managedObjectModel retain];
	});
	
	return _managedObjectModel;
}

/// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
		
		NSURL *storeURL = [[self.applicationDocumentsDirectory
			URLByAppendingPathComponent:kCoreDataSQLiteExtensionlessFileame]
			URLByAppendingPathExtension:@"sqlite"];
		if (!storeURL)
			@throw [NSException exceptionWithName:NSInvalidArgumentException
				reason:[NSString stringWithFormat:@"Unable to find app document with filename “%@”.",
					[kCoreDataSQLiteExtensionlessFileame stringByAppendingPathExtension:@"sqlite"]]
				userInfo:nil];
		
		NSError *pscError = nil;
		NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&pscError];
		if (!persistentStore)
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
				reason:@"There was an error creating or loading the application's saved data."
				userInfo:@{ NSUnderlyingErrorKey: pscError }];
	});
	
	return _persistentStoreCoordinator;
}

/// The managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
		if (!coordinator)
			return;
		
		_managedObjectContext = [NSManagedObjectContext new];
		_managedObjectContext.persistentStoreCoordinator = coordinator;
	});
	
	return _managedObjectContext;
}
/// Used to prevent creating the `managedObjectContext` as a side-effect when we only want to know if one has been created yet.
- (BOOL)hasManagedObjectContext {
	return (_managedObjectContext != nil);
}

- (void)saveContext
{
	if (!self.hasManagedObjectContext)
		return;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	
	if (managedObjectContext.hasChanges) {
		NSError *mocError = nil;
		BOOL successfullySaved = [managedObjectContext save:&mocError];
		
		if (!successfullySaved)
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
				reason:@"There was an error saving the application's data."
				userInfo:@{ NSUnderlyingErrorKey: mocError }];
	}
}


@end
