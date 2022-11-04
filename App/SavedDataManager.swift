// Rustle
// @author: Slipp Douglas Thompson

import UIKit.UIApplication
import CoreData



// MARK: - Constants & Statics

fileprivate let mainBundlePlaceholder: [Bundle]? = nil
fileprivate let synchronouslyQueuePlaceholder: OperationQueue? = nil



class SavedDataManager
{
	enum Error : Swift.Error {
		case unableToOpenCoreDataDBFile(String)
		case creatingOrLoadingSaveData(String, underlyingError: Swift.Error)
		case savingData(String, underlyingError: Swift.Error)
	}
	
	
	// MARK: Lifecycle
	
	private static var _shared = SavedDataManager()
	class var shared: SavedDataManager { _shared }
	
	init()
	{
		registerAppNotifications()
	}
	
	deinit
	{
		deregisterAppNotifications()
		
		managedObjectContext = nil
		persistentStoreCoordinator = nil
		managedObjectModel = nil
	}
	
	
	// MARK: App Notification Handlers
	
	func registerAppNotifications()
	{
		let app = UIApplication.shared
		let center = NotificationCenter.default
		
		center.addObserver(forName: UIApplication.didEnterBackgroundNotification,
			object: app,
			queue: synchronouslyQueuePlaceholder,
			using: { _ in try! self.saveContext() }
		)
		center.addObserver(forName: UIApplication.willTerminateNotification,
			object: app,
			queue: synchronouslyQueuePlaceholder,
			using: { _ in try! self.saveContext() }
		)
	}
	
	func deregisterAppNotifications()
	{
		let center = NotificationCenter.default
		center.removeObserver(self)
	}
	
	
	// MARK: Core Data Stack
	
	static let coreDataSQLiteExtensionlessFilename = "Rustle"
	
	/// The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
	private(set) lazy var managedObjectModel: NSManagedObjectModel! = NSManagedObjectModel.mergedModel(from: mainBundlePlaceholder)
	
	/// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
	private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator! = try! createPersistentStoreCoordinator()
	
	private func createPersistentStoreCoordinator() throws -> NSPersistentStoreCoordinator
	{
		let newCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		let documentsDirectory = (UIApplication.shared.delegate as! AppDelegate).documentsDirectory
		let storeURL = documentsDirectory
			.appendingPathComponent(Self.coreDataSQLiteExtensionlessFilename)
			.appendingPathExtension("sqlite")
		guard UIApplication.shared.canOpenURL(storeURL) else {
			let filename = URL(string: Self.coreDataSQLiteExtensionlessFilename)!.appendingPathExtension("sqlite")
			throw Error.unableToOpenCoreDataDBFile("Unable to find app document with filename “\(filename)”.")
		}
		
		do {
			_ = try newCoordinator.addPersistentStore(type: .sqlite, configuration: nil, at: storeURL, options: nil)
		} catch {
			throw Error.creatingOrLoadingSaveData("There was an error creating or loading the application's saved data.", underlyingError: error)
		}
		
		return newCoordinator
	}
	
	/// The managed object context for the application (which is already bound to the persistent store coordinator for the application.)
	private(set) lazy var managedObjectContext: NSManagedObjectContext! = createManagedObjectContext()
	
	private func createManagedObjectContext() -> NSManagedObjectContext?
	{
		guard let coordinator = self.persistentStoreCoordinator else {
			return nil
		}
		
		let newContext = NSManagedObjectContext(.mainQueue)
		newContext.persistentStoreCoordinator = coordinator
		return newContext
	}
	
	/// Used to prevent creating the `managedObjectContext` as a side-effect when we only want to know if one has been created yet.
	var hasManagedObjectContext: Bool {
		return (managedObjectContext != nil)
	}
	
	func saveContext() throws
	{
		guard hasManagedObjectContext else { return }
		
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				throw Error.savingData("There was an error saving the application's data.", underlyingError: error)
			}
		}
	}
	
	
}
