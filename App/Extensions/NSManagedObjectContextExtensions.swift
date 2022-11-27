//
//  NSManagedObjectContextExtensions.swift
//  Rustle
//
//  Created by Cap'n Slipp on 11/27/22.
//  Copyright © 2022 Cap'n Slipp. All rights reserved.
//

import CoreData



extension NSManagedObjectContext
{
	func registeredObject<T>(for objectID: NSManagedObjectID, _: T.Type) -> T?
		where T : NSManagedObject
	{
		return registeredObject(for: objectID) as! T?
	}
	
	
	func object<T>(with objectID: NSManagedObjectID, _: T.Type) -> T
		where T : NSManagedObject
	{
		return object(with: objectID) as! T
	}
	
	
	func existingObject<T>(with objectID: NSManagedObjectID, _: T.Type) throws -> T
		where T : NSManagedObject
	{
		return try existingObject(with: objectID) as! T
	}
	
	
	func registeredObjects<T>(_: T.Type) -> Set<T>
		where T : NSManagedObject
	{
		return Set<T>(registeredObjects.lazy.map{ $0 as! T })
	}
}
