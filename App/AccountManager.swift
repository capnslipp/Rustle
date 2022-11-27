// Rustle
// @author: Slipp Douglas Thompson

import Foundation
import os
import CoreData



fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "account")



class AccountManager
{
	enum Error : Swift.Error {
		case accountTypeNotTwitter(String)
		case userAndTwitterUserAreDifferentTwitterAccounts(String)
	}
	
	
	static let TwitterClientID = "bmRxSTRTYmVhRlBWSjR1eDdWVXo6MTpjaQ"
	static let TwitterBearerToken = "AAAAAAAAAAAAAAAAAAAAANIljQEAAAAAqe%2FC9OBix0ZxOhGaObDXkiVCxKA%3Da0y9mgiQzfBt91PRqOyrUEsp5T3mcn8w2vCu2Cy7Usdesqci9z"
	static let TwitterCallbackURL = URL(string: "rustle://authentication-finished")!
	
	
	// MARK: Lifecycle
	
	private static var _shared = AccountManager()
	class var shared: AccountManager { _shared }
	
	init()
	{
	}
	
	
	// MARK: User & Client Vars
	
	private var _twiftClient: TwiftClient?
	
	private(set) var twitterUser: TwiftUser?
	
	private var _user: User?
	private(set) var user: User? {
		get {
			try! populateUser()
			return _user
		}
		set {
			_user = newValue
			if _user == nil {
				twitterUser = nil // prevent recreation of `_user` by `populateUser()`
			}
		}
	}
	
	@discardableResult
	private func populateUser() throws -> User?
	{
		guard let twitterUser = twitterUser else {
			// If there's no `TwiftUser`, we can't do anything to find/create/update a `User`, so return `nil` to signify populate failed.
			return nil
		}
		
		let managedObjectContext: NSManagedObjectContext = SavedDataManager.shared.managedObjectContext
		
		if let user = _user {
			// Update the `User` from the `TwiftUser`
			
			guard String(user.twitterID) == twitterUser.id else {
				throw Error.userAndTwitterUserAreDifferentTwitterAccounts("Unexpectedly, the `User` and `TwiftUser` reference different twitter accounts (User: twitter ID \(user.twitterID); TwiftUser: twitter ID \(twitterUser.id).")
			}
			
			user.update(fromTwiftUser: twitterUser, inContext: managedObjectContext)
		}
		else { // _user == nil
			let twitterUserID = Int64(twitterUser.id)!
			
			// Attempt to find an existing `User` in the DB
			_user = User.find(byTwitterID: twitterUserID, inContext: managedObjectContext)
			
			if _user != nil {
				// Update the found `User` based on the `TwiftUser`
				logger.info("Found User with Twitter ID \(twitterUserID) in CoreData DB, and updated fields.")
				_user!.update(fromTwiftUser: twitterUser, inContext: managedObjectContext)
			}
			else {
				// Create a `User` based on the `TwiftUser`
				logger.info("Creating new User with Twitter ID \(twitterUserID).")
				_user = User.create(fromTwiftUser: twitterUser, inContext: managedObjectContext)
			}
		}
		
		if _user!.hasChanges {
			try SavedDataManager.shared.saveContext()
		}
		return _user
	}
	
	
	// MARK: Authentication
	
	private(set) var isAuthenticated: Bool = false
	
	func authenticate() async -> Bool
	{
		guard !isAuthenticated else {
			logger.error("\(self) is already authenticated.  If trying to change the authentication, you need to deauthenticate first.")
			return false
		}
		
		do {
			let twitterOAuthUser = try await TwiftAuthentication().authenticateUser(clientId: AccountManager.TwitterClientID, redirectUri: AccountManager.TwitterCallbackURL,
				scope: [ .tweetRead, .usersRead, .offlineAccess ]
			)
			
			await updateTwiftClient(token: twitterOAuthUser)
			isAuthenticated = true
			let twiftClient = _twiftClient!
			
			let result = try await twiftClient.getMe(fields: .all.subtracting([ \.pinnedTweetId ]))
			twitterUser = result.data
		} catch {
			logger.error("\(error.localizedDescription)")
			return false
		}
		
		return true
	}
	
	func deauthenticate() -> Bool
	{
		guard isAuthenticated else {
			logger.error("\(self) isn't currently authenticated.")
			return false
		}
		
		twitterUser = nil
		_twiftClient = nil
		isAuthenticated = false
		
		return true
	}
	
	
	private func updateTwiftClient(token: TwiftOAuth2User) async {
		_twiftClient = await TwiftClient(oauth2User: token, onTokenRefresh: { token in
			Task{
				await self.updateTwiftClient(token: token)
			}
		})
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
