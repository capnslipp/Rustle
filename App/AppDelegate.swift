// Rustle
// @author: Slipp Douglas Thompson

import UIKit



@main
class AppDelegate : UIResponder, UIApplicationDelegate
{
	var window: UIWindow?
	
	
	var savedDataMan: SavedDataManager!
	var accountMan: AccountManager!
	
	
	
	/// Override point for customization after application launch.
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{
		// Preempt initialization of managers
		self.savedDataMan = SavedDataManager.shared
		self.accountMan = AccountManager.shared
	
		return true
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
	}
	
	
	// MARK: Public Utils
	
	let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}
