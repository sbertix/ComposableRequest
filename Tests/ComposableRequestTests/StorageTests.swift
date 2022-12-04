//
//  StorageTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 04/11/20.
//

 import XCTest

 import KeychainAccess
 import Requests

 @testable import EncryptedStorages
 @testable import Storages

/// A static item.
 private let item = Item.default

/// A `class` defining all `Storage` test cases.
 final class StorageTests: XCTestCase {
    // MARK: Processors

    /// Process a `NonThrowingStorage`.
    ///
    /// - parameters:
    ///     - storage: A valid `NonThrowingStorage`.
    ///     - function: The function from where it was called.
    private func process<S: NonThrowingStorage>(_ storage: S, function: String = #function) where S.Item == Item {
        // Empty.
        storage.empty()
        XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(function), #\(#line))")
        // Store `item`.
        XCTAssert(storage.store(item) == item, "Stored \(item) did not match (\(function), #\(#line))")
        XCTAssert(storage.item(matching: item.label) == item, "\(storage) did not cache item (\(function), #\(#line))")
        XCTAssert(!storage.items().isEmpty, "\(storage) should not be empty (\(function), #\(#line))")
        // Delete `item`.
        XCTAssert(storage.discard(item.label) == item, "\(storage) did not discard item (\(function), #\(#line))")
        XCTAssert(storage.item(matching: item.label) == nil, "\(storage) did not discard item (\(function), #\(#line))")
        XCTAssert(storage.items().isEmpty, "\(storage) did not discard item (\(function), #\(#line))")
        // Empty.
        XCTAssert(storage.store(item) == item, "Stored \(item) did not match (\(function), #\(#line))")
        XCTAssert(storage.item(matching: item.label) == item, "\(storage) did not cache item (\(function), #\(#line))")
        XCTAssert(!storage.items().isEmpty, "\(storage) should not be empty (\(function), #\(#line))")
        storage.empty()
        XCTAssert(storage.item(matching: item.label) == nil, "\(storage) did not empty item (\(function), #\(#line))")
        XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(function), #\(#line))")
        // `Storable` accessories.
        XCTAssert(item.store(in: storage) == item, "Stored \(item) did not match (\(function), #\(#line))")
        XCTAssert(Item.matching(item.label, in: storage) == item, "Stored \(item) did not match (\(function), #\(#line))")
    }

    /// Process a `ThrowingStorage`.
    ///
    /// - parameters:
    ///     - storage: A valid `NonThrowingStorage`.
    ///     - function: The function from where it was called.
    private func process<S: ThrowingStorage>(_ storage: S, function: String = #function) throws where S.Item == Item {
        // Empty.
        try storage.empty()
        try XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(function), #\(#line))")
        // Store `item`.
        try XCTAssert(storage.store(item) == item, "Stored \(item) did not match (\(function), #\(#line))")
        try XCTAssert(storage.item(matching: item.label) == item, "\(storage) did not cache item (\(function), #\(#line))")
        try XCTAssert(!storage.items().isEmpty, "\(storage) should not be empty (\(function), #\(#line))")
        // Delete `item`.
        try XCTAssert(storage.discard(item.label) == item, "\(storage) did not discard item (\(function), #\(#line))")
        try XCTAssert(storage.item(matching: item.label) == nil, "\(storage) did not discard item (\(function), #\(#line))")
        try XCTAssert(storage.items().isEmpty, "\(storage) did not discard item (\(function), #\(#line))")
        // Empty.
        try XCTAssert(storage.store(item) == item, "Stored \(item) did not match (\(function), #\(#line))")
        try XCTAssert(storage.item(matching: item.label) == item, "\(storage) did not cache item (\(function), #\(#line))")
        try XCTAssert(!storage.items().isEmpty, "\(storage) should not be empty (\(function), #\(#line))")
        try storage.empty()
        try XCTAssert(storage.item(matching: item.label) == nil, "\(storage) did not empty item (\(function), #\(#line))")
        try XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(function), #\(#line))")
        // `Storable` accessories.
        XCTAssert(try item.store(in: storage) == item, "Stored \(item) did not match (\(function), #\(#line))")
        XCTAssert(try Item.matching(item.label, in: storage) == item, "Stored \(item) did not match (\(function), #\(#line))")
    }

    /// Process some `Storage`.
    ///
    /// - parameters:
    ///     - storage: A valid `Storage`.
    ///     - function: The function from where it was called.
    private func process<S: Storage>(storage: S, function: String = #function, line: Int = #line) throws where S.Item == Item {
        // Empty.
        try S.empty(storage)
        try XCTAssert(S.items(in: storage).isEmpty, "\(storage) did not empty (\(function), #\(#line))")
        // Store `item`.
        try XCTAssert(S.store(item, in: storage) == item, "Stored \(item) did not match (\(function), #\(#line))")
        try XCTAssert(S.item(matching: item.label, in: storage) == item, "\(storage) did not cache item (\(function), #\(#line))")
        try XCTAssert(!S.items(in: storage).isEmpty, "\(storage) should not be empty (\(function), #\(#line)")
        // Delete `item`.
        try XCTAssert(S.discard(item.label, in: storage) == item, "\(storage) did not discard item (\(function), #\(#line))")
        try XCTAssert(S.item(matching: item.label, in: storage) == nil, "\(storage) did not discard item (\(function), #\(#line))")
        try XCTAssert(S.items(in: storage).isEmpty, "\(storage) did not discard item (\(function), #\(#line))")
        // Empty.
        try XCTAssert(S.store(item, in: storage) == item, "Stored \(item) did not match (\(function), #\(#line)")
        try XCTAssert(S.item(matching: item.label, in: storage) == item, "\(storage) did not cache item (\(function), #\(#line))")
        try XCTAssert(!S.items(in: storage).isEmpty, "\(storage) should not be empty (\(function), #\(#line))")
        try S.empty(storage)
        try XCTAssert(S.item(matching: item.label, in: storage) == nil, "\(storage) did not empty item (\(function), #\(#line))")
        try XCTAssert(S.items(in: storage).isEmpty, "\(storage) did not empty (\(function), #\(#line))")
    }

    // MARK: Cases

    //    /// Test `KeychainStorage`.
    //    func testKeychainStorage() throws {
    //        let storage = KeychainStorage<Item>()
    //        try process(storage)
    //        try process(storage: storage)
    //        try process(storage: AnyStorage(storage))
    //    }

    /// Test `TransientStorage`.
    func testTransientStorage() {
        let storage = TransientStorage<Item>()
        // Empty.
        storage.empty()
        XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(#function), #\(#line))")
        // Store `item`.
        XCTAssert(storage.store(item) == item, "Stored \(item) did not match (\(#function), #\(#line))")
        XCTAssert(storage.item(matching: item.label) == nil, "\(storage) did not empty (\(#function), #\(#line))")
        XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(#function), #\(#line))")
        // Delete `item`.
        XCTAssert(storage.discard(item.label) == nil, "\(storage) did not empty (\(#function), #\(#line))")
        XCTAssert(storage.item(matching: item.label) == nil, "\(storage) did not empty (\(#function), #\(#line))")
        XCTAssert(storage.items().isEmpty, "\(storage) did not empty (\(#function), #\(#line))")
    }

    /// Test `UserDefaultsStorage`.
    func testUserDefaultsStorage() throws {
        let storage = UserDefaultsStorage<Item>()
        process(storage)
        try process(storage: storage)
        try process(storage: AnyStorage(storage))
    }
 }
