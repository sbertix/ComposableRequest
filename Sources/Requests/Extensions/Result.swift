//
//  Result.swift
//  Requests
//
//  Created by Stefano Bertagno on 07/12/22.
//

import Foundation

public extension Result where Failure == any Error {
    /// Generate a result from
    /// an async task.
    ///
    /// - parameter result: A result factory.
    /// - returns: A valid `Result`.
    static func `async`(_ result: () async throws -> Success) async -> Result<Success, Failure> {
        do { return .success(try await result()) } catch { return .failure(error) }
    }
}
