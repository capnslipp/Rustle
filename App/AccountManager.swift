// Rustle
// @author: Slipp Douglas Thompson

import Foundation
import Accounts
import os



fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "account")



class AccountManager
{
	enum Error : Swift.Error {
		case accountTypeNotTwitter(String)
	}
	
	
	// MARK: Lifecycle
	
	private static var _shared = AccountManager()
	class var shared: AccountManager { _shared }
	
	init()
	{
	}
	
	
	// MARK: Authentication
	
	private(set) var isAuthenticated: Bool = false
	
	func authenticate(usingTwitterAccount twitterAccount: ACAccount) throws -> Bool
	{
		guard !isAuthenticated else {
			logger.error("\(self) is already authenticated.  If trying to change the authentication, you need to deauthenticate first.")
			return false
		}
		
		let isTwitterType = twitterAccount.accountType.identifier == ACAccountTypeIdentifierTwitter
		guard isTwitterType else {
			throw Error.accountTypeNotTwitter("Invalid twitterAccount \(twitterAccount).  The account must be a Twitter account.")
		}
		
		// @todo: set up ivars using `twitterAccount`
		
		return true
	}
}



extension AccountManager : CustomStringConvertible
{
	// Default implementation that just uses `dump(…)`'s output.
	var description: String {
		return "<\(Self.self) " +
			"isAuthenticated: \(isAuthenticated) " +
			">"
	}
}
