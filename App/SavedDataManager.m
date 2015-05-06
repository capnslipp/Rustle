// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

#import "SavedDataManager.h"

#import <UIKit/UIApplication.h>
#import "AppDelegate.h"



#pragma mark - Constants & Statics

NSString *const kCoreDataSQLiteExtensionlessFileame = @"GTCoreBluetoothDemo";

NSArray *const kMainBundlePlaceholder = nil;
NSOperationQueue *const kSynchronouslyQueuePlaceholder = nil;

static SavedDataManager *sSharedManager = nil;



@interface SavedDataManager ()

- (void)registerAppNotifications;
- (void)deregisterAppNotifications;

// Core Data
@property(assign, readonly, nonatomic) BOOL hasManagedObjectContext;

@end



@implementation SavedDataManager


#pragma mark Lifecycle

+ (instancetype)sharedManager
{
	static dispatch_once_t sOnceToken;
	dispatch_once(&sOnceToken, ^{
		sSharedManager = [SavedDataManager new];
	});
	
	return sSharedManager;
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	[self registerAppNotifications];
	
	return self;
}

- (void)dealloc
{
	[self deregisterAppNotifications];
	
	[_managedObjectContext release];
	_managedObjectContext = nil;
	[_persistentStoreCoordinator release];
	_persistentStoreCoordinator = nil;
	[_managedObjectModel release];
	_managedObjectModel = nil;
	
	[super dealloc];
}


#pragma mark App Notification Handlers

- (void)registerAppNotifications
{
	UIApplication *app = UIApplication.sharedApplication;
	NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
	
	[center addObserverForName:UIApplicationDidEnterBackgroundNotification
		object:app
		queue:kSynchronouslyQueuePlaceholder
		usingBlock:^(NSNotification *note) {
			[self saveContext];
		}
	];
	[center addObserverForName:UIApplicationWillTerminateNotification
		object:app
		queue:kSynchronouslyQueuePlaceholder
		usingBlock:^(NSNotification *note) {
			[self saveContext];
		}
	];
}

- (void)deregisterAppNotifications
{
	NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
	
	[center removeObserver:self];
}


#pragma mark Core Data Stack

@synthesize managedObjectModel=_managedObjectModel, persistentStoreCoordinator=_persistentStoreCoordinator, managedObjectContext=_managedObjectContext;

/// The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel == nil) {
		_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:kMainBundlePlaceholder];
		[_managedObjectModel retain];
	};
	
	return _managedObjectModel;
}

/// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator == nil) {
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
		
		NSURL *documentsDirectory = ((AppDelegate *)UIApplication.sharedApplication.delegate).documentsDirectory;
		NSURL *storeURL = [[documentsDirectory
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
	}
	
	return _persistentStoreCoordinator;
}

/// The managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext == nil) {
		NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
		if (!coordinator)
			return nil;
		
		_managedObjectContext = [NSManagedObjectContext new];
		_managedObjectContext.persistentStoreCoordinator = coordinator;
	}
	
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