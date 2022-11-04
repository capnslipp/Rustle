// Rustle
// @author: Slipp Douglas Thompson

import UIKit
import Accounts
import os



fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "titleView")



// MARK: - Constants

let appName = "Rustle"



// MARK: - Class

class TitleViewController : UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
	enum Error : Swift.Error {
		case nilStoryboardIDProperty(String, propertyName: String)
		case unknownTableView
		case outOfRangeInnermostIndexPath(indexPath: IndexPath, varName: String, varValue: Int)
	}
	
	
	@IBOutlet var twitterLoginButton: UIButton!
	
	
	private var _twitterAccountsForPopover: [ACAccount] = []
	
	
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
	
	weak var twitterTableController: UITableViewController!
	
	var isTwitterPopoverActive: Bool {
		// @warning: Assumption that if a `twitterTableController` instance is alive, the popover is being presented.
		// 	We might be able to do better— but Storyboards seem to use `UIPopoverPresentationController` not `UIPopoverController`, and the former doesn't give us much info to work with.
		return (twitterTableController != nil)
	}
	
	private var _twitterPopoverSequeID: String? = nil
	@IBInspectable var twitterPopoverSequeID: String {
		get {
			guard let value = _twitterPopoverSequeID else {
				let propertyName = "twitterPopoverSequeID"
				Error.nilStoryboardIDProperty("\(self)'s \(propertyName) must be set to prior to using the object.  You likely need to configure this in the storyboard under the \(type(of: self))'s User Defined Runtime Attributes.", propertyName: propertyName).trap()
				return "" // never run
			}
			return value
		}
		set { _twitterPopoverSequeID = newValue }
	}
	
	private var _twitterPopoverTableCellReuseID: String? = nil
	@IBInspectable var twitterPopoverTableCellReuseID: String {
		get {
			guard let value = _twitterPopoverTableCellReuseID else {
				let propertyName = "twitterPopoverTableCellReuseID"
				Error.nilStoryboardIDProperty("\(self)'s \(propertyName) must be set to prior to using the object.  You likely need to configure this in the storyboard under the \(type(of: self))'s User Defined Runtime Attributes.", propertyName: propertyName).trap()
				return "" // never run
			}
			return value
		}
		set { _twitterPopoverTableCellReuseID = newValue }
	}
	
	
	// MARK: UIViewController Aherence
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// @fillin: Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		
		// @fillin: Dispose of any resources that can be recreated.
	}
	
	
	// MARK: Actions
	
	@IBAction func openTwitterLogin(_ sender: Any)
	{
		let accountStore = ACAccountStore()
		let twitterAccountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
		
		accountStore.requestAccessToAccounts(with: twitterAccountType,
			options: nil,
			completion: { (granted, error) in
				DispatchQueue.main.sync{
					if (!granted) {
						self.presentTwitterAccessNotGrantedAlert()
					}
					else {
						let twitterAccounts = accountStore.accounts(with: twitterAccountType) as! [ACAccount]
						self.askForTwitterAcount(from: twitterAccounts)
					}
				}
			}
		)
	}
	
	func askForTwitterAcount(from twitterAccounts: [ACAccount])
	{
		let accountCount = twitterAccounts.count
		
		if accountCount == 0 {
			presentNoTwitterAccountsAlert()
		}
		else if accountCount == 1 {
			initiateLogin(withAccount: twitterAccounts[0])
		}
		else { // accountCount ≥ 2
			let twitterPopoverSequeID = self.twitterPopoverSequeID
			
			let canPerformSeque = shouldPerformSegue(withIdentifier: twitterPopoverSequeID, sender: self)
			if !canPerformSeque {
				return
			}
			
			_twitterAccountsForPopover = twitterAccounts // for later use by `tableView:numberOfRowsInSection:`, `tableView:cellForRowAtIndexPath:`, `tableView:didSelectRowAtIndexPath:`
			
			performSegue(withIdentifier: twitterPopoverSequeID, sender: self)
		}
	}
	
	func initiateLogin(withAccount twitterAccount: ACAccount)
	{
		logger.info("Using twitter account: \(twitterAccount)")
		try! AccountManager.shared.authenticate(usingTwitterAccount: twitterAccount)
	}
	
	
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
	
	
	// MARK: Navigation
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
	{
		if identifier == self.twitterPopoverSequeID {
			return !isTwitterPopoverActive
		}
		else {
			return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == twitterPopoverSequeID {
			let destController = segue.destination as! UITableViewController
			
			let tableView = destController.tableView!
			tableView.dataSource = self
			tableView.delegate = self
			
			twitterTable = tableView
			twitterTableController = destController
		}
	}
	
	
	// MARK: KVO
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		guard let object = object else {
			return
		}
		
		if object as? UITableView == twitterTable && keyPath == "contentSize" {
			let tableView = object as! UITableView
			popoverTableView(tableView, didChangeContentSize: tableView.contentSize)
		}
	}
	
	
	// MARK: Twitter-Popover UITableViewDataSource & UITableViewDelegate Responsibilities
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if tableView == self.twitterTable
		{
			switch (section) {
				case 0:
					return _twitterAccountsForPopover.count
				
				default:
					return 0
			}
		}
		
		return 0
	}
	
	func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if tableView == self.twitterTable
		{
			let twitterAccounts = _twitterAccountsForPopover
			
			let innermostIndex = indexPath.last!
			if innermostIndex >= twitterAccounts.count {
				Error.outOfRangeInnermostIndexPath(indexPath: indexPath, varName: "twitterAccounts.count", varValue: twitterAccounts.count).trap()
			}
			
			let twitterAccount = twitterAccounts[innermostIndex]
			let tableCell = tableView.dequeueReusableCell(withIdentifier: self.twitterPopoverTableCellReuseID)!
			tableCell.textLabel!.text = twitterAccount.accountDescription
			
			return tableCell
		}
		
		Error.unknownTableView.trap()
		return UITableViewCell() // never run
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
	{
		if tableView == self.twitterTable
		{
			let twitterAccounts = _twitterAccountsForPopover
			
			let innermostIndex = indexPath.last!
			if innermostIndex >= twitterAccounts.count {
				Error.outOfRangeInnermostIndexPath(indexPath: indexPath, varName: "twitterAccounts.count", varValue: twitterAccounts.count).trap()
			}
			
			let twitterAccount = twitterAccounts[innermostIndex]
			
			self.twitterTableController.dismiss(animated: true)
			self.twitterTableController = nil
			self.twitterTable = nil
			
			initiateLogin(withAccount: twitterAccount)
		}
	}
	
	func popoverTableView(_ tableView: UITableView, didChangeContentSize contentSize: CGSize)
	{
		let tableViewController = self.twitterTableController!
		
		// size down the size of the rows
		
		let existingPreferredContentSize = tableViewController.preferredContentSize
		if existingPreferredContentSize == contentSize {
			return // prevents recursive-ish calls
		}
		
		tableViewController.preferredContentSize = contentSize
		
		// disable scroll-ability unless the table's decently long
		
		let titleViewSize = self.view.bounds.size
		let shouldBeScrollable = (contentSize.height > titleViewSize.height * 0.75) // if taller than 3/4s the height of the screen
		tableView.isScrollEnabled = shouldBeScrollable
	}
}
