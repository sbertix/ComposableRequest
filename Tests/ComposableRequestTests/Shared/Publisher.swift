//
//  Publisher.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 10/03/21.
//

import Foundation
import XCTest

import CXShim

extension Publisher {
    /// Assert main thread.
    func assertMainThread() -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { _ in XCTAssert(Thread.isMainThread) },
                     receiveCompletion: { _ in XCTAssert(Thread.isMainThread) })
    }
    
    /// Assert background thread.
    func assertBackgroundThread() -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { _ in XCTAssert(!Thread.isMainThread) },
                     receiveCompletion: { _ in XCTAssert(!Thread.isMainThread) })
    }
}
