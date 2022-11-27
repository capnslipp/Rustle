//
//  User+CoreDataClass.swift
//  
//
//  Created by Cap'n Slipp on 11/26/22.
//
//

import Foundation
import CoreData

/// A user of Rustle.  Currently authenticated and identified by a Twitter account, but that may only be one of the possible auth/id methods in the future.
@objc(User)
public class User : NSManagedObject
{
	class func fetchRequest(byTwitterID twitterID: Int64) -> NSFetchRequest<User> {
		let request = fetchRequest()
		request.predicate = NSPredicate(format: "twitterID == %@", twitterID as NSNumber)
		return request
	}
	
	class func find(byTwitterID twitterID: Int64, inContext context: NSManagedObjectContext) -> User? {
		return try! context.fetch(fetchRequest(byTwitterID: twitterID)).first
	}
	
	
	static func create(fromTwiftUser twiftUser: TwiftUser, inContext context: NSManagedObjectContext) -> User
	{
		let user = User(context: context)
		user.update(fromTwiftUser: twiftUser, inContext: context)
		return user
	}
	
	
	func update(fromTwiftUser twiftUser: TwiftUser, inContext context: NSManagedObjectContext)
	{
		twitterID = Int64(twiftUser.id)!
		twitterUsername = twiftUser.username
		twitterName = twiftUser.name
		twitterBio = twiftUser.description
		twitterLocation = twiftUser.location
		twitterProfileImageURL = twiftUser.profileImageUrlLarger
	}
}
