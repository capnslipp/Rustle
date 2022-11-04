//
//  ErrorExtensions.swift
//  Rustle
//
//  Created by Cap'n Slipp on 11/3/22.
//  Copyright © 2022 Cap'n Slipp. All rights reserved.
//

import Foundation



extension Error
{
	/// Allows you to still use a Swift Error even when in a method or property implementat that's not allowed to throw.
	func trap() {
		try! { throw self }()
	}
}
