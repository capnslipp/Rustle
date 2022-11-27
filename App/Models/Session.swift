//
//  Session+CoreDataClass.swift
//  
//
//  Created by Cap'n Slipp on 11/26/22.
//
//

import Foundation
import CoreData

/// A session persists all of the created and downloaded data for a logged-in `User` on this device / iCloud account, regardless of whether that user is currently authenticated or not.
@objc(Session)
public class Session : NSManagedObject
{
	// MARK: Find By `objectID`
	
	class func find(byObjectID objectID: NSManagedObjectID, inContext context: NSManagedObjectContext) -> Session? {
		return try? context.existingObject(with: objectID, Session.self)
	}
	
	
	// MARK: Find By `user.twitterID`
	
	class func fetchRequest(byUserTwitterID twitterID: Int64) -> NSFetchRequest<Session> {
		let request = fetchRequest()
		request.predicate = NSPredicate(format: "user.twitterID == %@", twitterID as NSNumber)
		return request
	}
	
	class func find(byUserTwitterID twitterID: Int64, inContext context: NSManagedObjectContext) -> Session? {
		return try! context.fetch(fetchRequest(byUserTwitterID: twitterID)).first
	}
}
