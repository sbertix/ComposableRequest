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

/// A `class` defining all `Storage` test cases.
final class StorageTests: XCTestCase {
    // MARK: Generic

    private func test<S: Storage>(
        _ storage: S,
        item: Item = .default,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) throws where S.Item == Item {
        // Empty the storage.
        try storage.removeAll()
        XCTAssertTrue(Array(storage).isEmpty)
        // Store the item.
        var (inserted, value) = try storage.insert(item)
        XCTAssertTrue(inserted)
        XCTAssertEqual(value, item)
        XCTAssertEqual(Array(storage), [item])
        // Update an existing item.
        var updatedItem = item
        updatedItem.cookies.removeAll()
        (inserted, value) = try storage.insert(updatedItem)
        XCTAssertFalse(inserted)
        XCTAssertEqual(value, item)
        XCTAssertEqual(Array(storage), [updatedItem])
        // Delete an existing item.
        XCTAssertEqual(try storage.removeValue(forKey: item.id), updatedItem)
        // Store the item again.
        (inserted, value) = try storage.insert(updatedItem)
        XCTAssertTrue(inserted)
        XCTAssertEqual(value, updatedItem)
        // Delete existing items.
        try storage.removeAll()
        XCTAssertTrue(Array(storage).isEmpty)

        // Test type-erased storage.
        guard !(storage is AnyStorage<Item>) else { return }
        try test(AnyStorage(storage), item: item, file: file, function: function, line: line)
    }

    private func test<S: Storage>(
        transient storage: S,
        item: Item = .default,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) throws where S.Item == Item {
        // Empty the storage.
        try storage.removeAll()
        XCTAssertTrue(Array(storage).isEmpty)
        // "Store" the item.
        var (inserted, value) = try storage.insert(.default)
        XCTAssertFalse(inserted)
        XCTAssertEqual(value, .default)
        XCTAssertTrue(Array(storage).isEmpty)
        // "Delete" an "existing" item.
        XCTAssertNil(try storage.removeValue(forKey: Item.default.id))
        // "Store" the item again.
        (inserted, value) = try storage.insert(.default)
        XCTAssertFalse(inserted)
        XCTAssertEqual(value, .default)
        XCTAssertTrue(Array(storage).isEmpty)
        // "Delete" "existing" items.
        try storage.removeAll()
        XCTAssertTrue(Array(storage).isEmpty)

        // Test type-erased storage.
        guard !(storage is AnyStorage<Item>) else { return }
        try test(transient: AnyStorage(storage), item: item, file: file, function: function, line: line)
    }

    // MARK: Concrete

    /// Test `TransientStorage`.
    func testTransientStorage() throws {
        try test(transient: TransientStorage())
    }

    /// Test `UserDefaultsStorage`.
    func testUserDefaultsStorage() throws {
        try test(UserDefaultsStorage())
    }
}
