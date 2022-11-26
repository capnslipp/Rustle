//
//  TwiftExtensions.swift
//  Rustle
//
//  Created by Cap'n Slipp on 11/26/22.
//  Copyright © 2022 Cap'n Slipp. All rights reserved.
//


// Type aliases to dodge issue where we're asking for «module».«type» (e.g. `Twift.User`) but Swift (currently ≤5.7.1) thinks we're asking for «type».«subtype» (e.g. `Twift.Twift.User`, which doesn't exist).

import struct Twift.User
internal typealias TwiftUser = Twift.User
import struct Twift.OAuth2User
internal typealias TwiftOAuth2User = OAuth2User
import enum Twift.OAuth2Scope
internal typealias TwiftOAuth2Scope = OAuth2Scope
