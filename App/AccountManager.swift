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
	
	
	// MARK: Authentication
	
	private var _twiftClient: TwiftClient?
	
	public private(set) var twitterUser: TwiftUser?
	
	public private(set) var user: User?
	
	
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
		let twitterUser = twitterUser!
		
		// set up `user` vars using `twitterUser`
		
		let managedObjectContext: NSManagedObjectContext = SavedDataManager.shared.managedObjectContext
		
		let twitterUserID = Int64(twitterUser.id)!
		user = User.find(byTwitterID: twitterUserID, inContext: managedObjectContext)
		if user != nil {
			logger.info("Found User with Twitter ID \(twitterUserID) in CoreData DB, and updated fields.")
		} else {
			logger.info("Creating new User with Twitter ID \(twitterUserID).")
			user = User(context: managedObjectContext)
			user!.twitterID = twitterUserID
		}
		let user = user!
		user.twitterUsername = twitterUser.username
		user.twitterName = twitterUser.name
		user.twitterBio = twitterUser.description
		user.twitterLocation = twitterUser.location
		user.twitterProfileImageURL = twitterUser.profileImageUrlLarger
		
		try! SavedDataManager.shared.saveContext()
		
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
