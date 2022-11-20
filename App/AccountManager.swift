// Rustle
// @author: Slipp Douglas Thompson

import Foundation
import Twift
import os



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
	
	private var _twiftClient: Twift?
	
	public private(set) var twitterUser: User?
	
	
	private(set) var isAuthenticated: Bool = false
	
	func authenticate() async -> Bool
	{
		guard !isAuthenticated else {
			logger.error("\(self) is already authenticated.  If trying to change the authentication, you need to deauthenticate first.")
			return false
		}
		
		do {
			let twitterOAuthUser = try await Twift.Authentication().authenticateUser(clientId: AccountManager.TwitterClientID, redirectUri: AccountManager.TwitterCallbackURL,
				scope: [ .tweetRead, .usersRead, .offlineAccess ]
			)
			
			await updateTwiftClient(token: twitterOAuthUser)
			isAuthenticated = true
			let twiftClient = _twiftClient!
			
			let result = try await twiftClient.getMe(fields: .all.subtracting([ \.pinnedTweetId ]))
			twitterUser = result.data
		} catch {
			logger.error("\(error.localizedDescription)")
		}
		
		// @todo: set up ivars using `twitterAccount`
		
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
	
	
	private func updateTwiftClient(token: OAuth2User) async {
		_twiftClient = await Twift(oauth2User: token, onTokenRefresh: { token in
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



extension Set<User.Field>
{
	static let all: Self = [
		\.createdAt,
		\.description,
		\.entities,
		\.location,
		\.pinnedTweetId,
		\.profileImageUrl,
		\.protected,
		\.publicMetrics,
		\.url,
		\.verified,
		\.withheld
	]
}


extension Set<OAuth2Scope>
{
	static var all: Self {
		Self(OAuth2Scope.allCases)
	}
}
