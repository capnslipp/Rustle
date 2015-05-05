// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

@import UIKit;
@import CoreData;



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(retain, nonatomic) UIWindow *window;

// Core Data
@property(copy, readonly, nonatomic) NSURL *applicationDocumentsDirectory;
@property(retain, readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(retain, readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(retain, readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
- (void)saveContext;

@end
