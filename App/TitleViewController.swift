// Rustle
// @author: Slipp Douglas Thompson

import UIKit
import Twift
import os



fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "titleView")



// MARK: - Constants

let appName = "Rustle"



// MARK: - Class

class TitleViewController : UIViewController
{
	enum Error : Swift.Error {
		case nilStoryboardIDProperty(String, propertyName: String)
		case unknownTableView
		case outOfRangeInnermostIndexPath(indexPath: IndexPath, varName: String, varValue: Int)
	}
	
	
	@IBOutlet var twitterLoginButton: UIButton!
	@IBOutlet var twitterLogoutButton: UIButton!
	
	@IBOutlet var loggedinStatusLabel: UILabel!
	func updateLoggedinStatusLabel() {
		if let twitterUsername = AccountManager.shared.twitterUser?.username {
			loggedinStatusLabel.text = "Logged in as @\(twitterUsername)"
		} else {
			loggedinStatusLabel.text = "Logged in as @???"
		}
	}
	
	weak var twitterTable: UITableView! {
		willSet {
			if twitterTable != nil {
				twitterTable.removeObserver(self, forKeyPath: "contentSize")
			}
		}
		didSet {
			if twitterTable != nil {
				twitterTable.addObserver(self, forKeyPath: "contentSize", context: nil)
			}
		}
	}
	
	
	// MARK: UIViewController Aherence
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		twitterLoginButton.isHidden = true
		twitterLogoutButton.isHidden = true
		loggedinStatusLabel.isHidden = true
		
		if !AccountManager.shared.isAuthenticated {
			twitterLoginButton.isHidden = false
		} else {
			updateLoggedinStatusLabel()
			loggedinStatusLabel.isHidden = false
			
			twitterLogoutButton.isHidden = false
		}
		
		twitterLogoutButton.layer.borderWidth = 1.0
		twitterLogoutButton.layer.borderColor = UIColor.tintColor.cgColor
		twitterLogoutButton.layer.cornerRadius = 5
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		
		// @fillin: Dispose of any resources that can be recreated.
	}
	
	
	// MARK: Actions
	
	@IBAction func openTwitterLogin(_ sender: Any)
	{
		Task{
			twitterLoginButton.isEnabled = false
			
			let success = await AccountManager.shared.authenticate()
			guard success else {
				twitterLoginButton.isEnabled = true
				return
			}
			
			twitterLoginButton.isHidden = true
			
			updateLoggedinStatusLabel()
			loggedinStatusLabel.isHidden = false
			
			twitterLogoutButton.isEnabled = true
			twitterLogoutButton.isHidden = false
		}
	}
	
	@IBAction func logoutOfTwitter(_ sender: Any)
	{
		twitterLogoutButton.isEnabled = false
		
		let success = AccountManager.shared.deauthenticate()
		guard success else {
			twitterLogoutButton.isEnabled = true
			return
		}
		
		twitterLogoutButton.isHidden = true
		loggedinStatusLabel.isHidden = true
		
		twitterLoginButton.isEnabled = true
		twitterLoginButton.isHidden = false
	}
	
	//func askForTwitterAcount(from twitterAccounts: [ACAccount])
	//{
	//	let accountCount = twitterAccounts.count
	//	
	//	if accountCount == 0 {
	//		presentNoTwitterAccountsAlert()
	//	}
	//	else if accountCount == 1 {
	//		initiateLogin(withAccount: twitterAccounts[0])
	//	}
	//	else { // accountCount ≥ 2
	//		let twitterPopoverSequeID = self.twitterPopoverSequeID
	//		
	//		let canPerformSeque = shouldPerformSegue(withIdentifier: twitterPopoverSequeID, sender: self)
	//		if !canPerformSeque {
	//			return
	//		}
	//		
	//		_twitterAccountsForPopover = twitterAccounts // for later use by `tableView:numberOfRowsInSection:`, `tableView:cellForRowAtIndexPath:`, `tableView:didSelectRowAtIndexPath:`
	//		
	//		performSegue(withIdentifier: twitterPopoverSequeID, sender: self)
	//	}
	//}
	
	//func initiateLogin(withAccount twitterAccount: ACAccount)
	//{
	//	logger.info("Using twitter account: \(twitterAccount)")
	//	try! AccountManager.shared.authenticate(usingTwitterAccount: twitterAccount)
	//}
	
	
	// MARK: Alerts
	
	func presentTwitterAccessNotGrantedAlert() {
		presentSettingsDirectingAlert(withTitle: "Twitter Account Access Denied",
			message: "\(appName) requires access to a Twitter account for indentification." + "\n\n" +
				"\(appName)) does not use any information from Twitter other than your username, and \(appName)) will not post anything to Twitter." + "\n\n" +
				"Please use the Settings app to allow Twitter accounts on this device."
		)
	}
	
	func presentNoTwitterAccountsAlert() {
		presentSettingsDirectingAlert(withTitle: "No Twitter Accounts Found",
			message: "No Twitter accounts are set up." + "\n\n" +
				"Please use the Settings app to add a Twitter account."
		)
	}
	
	func presentSettingsDirectingAlert(withTitle title: String, message: String)
	{
		let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		let doPresentAlert = {
			self.present(errorAlert, animated: true)
		}
		
		errorAlert.addAction(UIAlertAction(title: "Dismiss", style: .default,
			handler: { _ in errorAlert.dismiss(animated: true) }
		))
		errorAlert.addAction(UIAlertAction(title: "iOS Settings", style: .default,
			handler: { _ in
				UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
			}
		))
		
		doPresentAlert()
	}
}
