//
//  Provider+Alias.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

// swiftlint:disable line_length
/// A `typealias` for a composition of `LockProvider`,
/// `SessionProvider` and `PagerProvider`.
public typealias LockSessionPagerProvider <Input, Offset, Output> = ConcatProvider3<LockProvider<Input, SessionProvider<PagerProvider <Offset, Output>>>,
                                                                                    SessionProvider<PagerProvider<Offset, Output>>,
                                                                                    PagerProvider<Offset, Output>>

/// A `typealias` for a composition of `LockProvider` and `SessionProvider`.
public typealias LockSessionProvider <Input, Output> = ConcatProvider<LockProvider<Input, SessionProvider<Output>>,
                                                                      SessionProvider<Output>>

/// A `typealias` for a composition of `SessionProvider` and `PagerProvider`.
public typealias SessionPagerProvider <Offset, Output> = ConcatProvider<SessionProvider<PagerProvider<Offset, Output>>,
                                                                        PagerProvider<Offset, Output>>
// swiftlint:enable line_length
