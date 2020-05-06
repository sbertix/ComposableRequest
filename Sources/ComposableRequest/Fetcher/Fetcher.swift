//
//  Fetcher.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `struct` defining concrete sub `struct`s for `Requestable`s.
public struct Fetcher<Request: Requestable, Response> {
    /// A `typealias` for pre-processing a `Request`, usually for authentication purposes.
    public typealias Preprocessor = (_ request: Request) -> Request
    
    /// A `typealias` for  processing a `Data` response.
    public typealias Processor = (_ response: Result<Data, Error>) -> Result<Response, Error>
    
    /// A `typealias` for returning the next `Fetchable` in the sequence, from a given optional `Response` and last request.
    public typealias Pager = (_ request: Request, _ response: Result<Response, Error>?) -> Request?
}
