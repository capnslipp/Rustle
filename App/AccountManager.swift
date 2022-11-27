// Rustle
// @author: Slipp Douglas Thompson

import Foundation
import os
import CoreData
import With



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
	
	
	// MARK: Session Var
	
	private var _session: Session?
	private(set) var session: Session? {
		get { _session }
		set {
			_session = newValue
			user = _session?.user
		}
	}
	
	@discardableResult
	private func populateSessionViaUser() throws -> Session?
	{
		guard let user = user else {
			// If there's no `User`, we can't do anything to find/create/update a `Session`, so return `nil` to signify populate failed.
			return nil
		}
		
		let managedObjectContext: NSManagedObjectContext = SavedDataManager.shared.managedObjectContext
		
		// Attempt to find an existing `Session` in the DB
		session = Session.find(byUserTwitterID: user.twitterID, inContext: managedObjectContext)
		
		if session != nil {
			logger.info("Found Session with Twitter ID \(user.twitterID) in CoreData DB.")
		}
		else {
			// Create a `Session` based on the `User`
			logger.info("Creating new Session with User#\(user.objectID).")
			session = with(Session(context: managedObjectContext)) { s in
				s.user = user
			}
		}
		
		if session!.hasChanges {
			try SavedDataManager.shared.saveContext()
		}
		return session
	}
	
	@discardableResult
	private func populateSession(withObjectID objectID: NSManagedObjectID) -> Session?
	{
		let managedObjectContext: NSManagedObjectContext = SavedDataManager.shared.managedObjectContext
		
		// Attempt to find an existing `Session` in the DB
		session = Session.find(byObjectID: objectID, inContext: managedObjectContext)
		if session != nil {
			logger.info("Found Session with objectID \(objectID) in CoreData DB.")
		}
		
		return session
	}
	
	/// Restore the `Session` from the DB via a Session's `NSManagedObjectID`.
	/// Useful for restoring at app lauch via a Session URI stored in UserDefaults.
	func restoreSession(withObjectID objectID: NSManagedObjectID) -> Bool
	{
		guard session == nil else {
			logger.error("\(self) already has a current session.  If trying to switch session or start authentication, you need to exit the session first.")
			return false
		}
		
		let success = (populateSession(withObjectID: objectID) != nil)
		return success
	}
	
	@discardableResult
	func exitCurrentSession() -> Bool
	{
		guard session != nil else {
			logger.error("\(self) doesn't currently have an active session.")
			return false
		}
		
		try! SavedDataManager.shared.saveContext()
		
		session = nil
		
		return true
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
		guard session == nil else {
			logger.error("\(self) already has a current session.  If trying to switch session or start authentication, you need to exit the session first.")
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
			
			let sessionSuccess = (try populateSessionViaUser() != nil)
			return sessionSuccess
		} catch {
			logger.error("\(error.localizedDescription)")
			return false
		}
	}
	
	@discardableResult
	func deauthenticate() -> Bool
	{
		guard isAuthenticated else {
			logger.error("\(self) isn't currently authenticated.")
			return false
		}
		isAuthenticated = false
		
		session = nil
		user = nil
		twitterUser = nil
		_twiftClient = nil
		
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
