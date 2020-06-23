//
//  Composable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `typealias` encompassing all composition request types.
public typealias RequestComposable = BodyComposable & HeaderComposable & MethodComposable & QueryComposable

/// A `typealias` encompassing all composition types.
public typealias Composable = PathComposable & RequestComposable

/// A `typealias` encompassing all parasable types.
public typealias Parsable = BodyParsable & HeaderParsable & QueryParsable
