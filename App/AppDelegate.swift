// Rustle
// @author: Slipp Douglas Thompson

import UIKit
import CoreData



@main
class AppDelegate : UIResponder, UIApplicationDelegate
{
	struct DefaultsKeys
	{
		/// `DefaultsKeys` is static-only and doesn't allow instantiation.
		private init() {}
		
		static let sessionID = "sessionID"
	}
	
	
	var window: UIWindow?
	
	
	var savedDataMan: SavedDataManager!
	var accountMan: AccountManager!
	
	
	/// Override point for customization after application launch.
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{
		// Preempt initialization of managers
		self.savedDataMan = SavedDataManager.shared
		self.accountMan = AccountManager.shared
		
		// Restore previous Session
		let lastSessionObjectID: NSManagedObjectID? = {
			guard let uri = UserDefaults.standard.url(forKey: DefaultsKeys.sessionID) else {
				return nil
			}
			guard let objectID = savedDataMan.persistentStoreCoordinator.managedObjectID(forURIRepresentation: uri) else {
				return nil
			}
			return objectID
		}()
		if let lastSessionObjectID = lastSessionObjectID {
			let success = accountMan.restoreSession(withObjectID: lastSessionObjectID)
			if !success {
				// Clear up invalid UserDefault entry
				UserDefaults.standard.removeObject(forKey: DefaultsKeys.sessionID)
			}
		}
	
		return true
	}
	
	private func saveSessionID()
	{
		if let sessionObjectID = accountMan.session?.objectID {
			UserDefaults.standard.set(sessionObjectID.uriRepresentation(), forKey: DefaultsKeys.sessionID)
		} else {
			UserDefaults.standard.removeObject(forKey: DefaultsKeys.sessionID)
		}
	}
	
	/// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	/// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	func applicationWillResignActive(_ application: UIApplication)
	{
	}
	
	/// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	/// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	func applicationDidEnterBackground(_ application: UIApplication)
	{
		saveSessionID()
	}
	
	/// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	func applicationWillEnterForeground(_ application: UIApplication)
	{
	}
	
	/// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	func applicationDidBecomeActive(_ application: UIApplication)
	{
	}
	
	/// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	func applicationWillTerminate(_ application: UIApplication)
	{
		saveSessionID()
	}
}
