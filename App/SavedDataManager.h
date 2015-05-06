// GTCoreBluetoothDemo
// @author: Slipp Douglas Thompson

@import Foundation;
@import CoreData;



@interface SavedDataManager : NSObject

+ (instancetype)sharedManager;

// Core Data
@property(retain, readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(retain, readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(retain, readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
- (void)saveContext;

@end
