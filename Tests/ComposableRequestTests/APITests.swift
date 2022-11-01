//
//  APITests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation
import XCTest

@testable import Core

enum Keys: String, EndpointKey {
    case reference
}

enum OtherKeys: String, EndpointKey {
    typealias Input = String
    case inherit
}

/// A `class` defining tests for composition `protocol`s.
final class APItests: XCTestCase {
    func testBuilder() {
        let group = EndpointGroup {
            Method(.post)
            Path("path")
            Query("this should be replaced", forKey: "key")
            Headers("this should be replaced", forKey: "key")
            Body(.init())
            Service(.background)
            Cellular(false)
            Timeout(15)
            Constrained(false)
            Expensive(false)
            
            Endpoint(Keys.reference) {
                Method(.connect)
                Path("final")
                Query("value", forKey: "key")
                Headers("value", forKey: "key")
                Body(nil)
                Service(.default)
                Cellular(true)
                Timeout(60)
                Constrained(true)
                Expensive(true)
            }
            
            EndpointGroup {
                Path("middle")
                Endpoint(OtherKeys.inherit) {
                    Path("final")
                    Query($0, forKey: "key")
                    Headers($0, forKey: "key")
                }
            }
        }
        
        let resolvedReference = group.components(for: Keys.reference)!
        let resolvedInherit = group.components(for: OtherKeys.inherit, with: "value")!
        
        XCTAssertEqual(resolvedReference.components[.method]?.value as? HTTPMethod, .connect)
        XCTAssertEqual(resolvedReference.components[.path]?.value as? String, "path/final")
        XCTAssertEqual(resolvedReference.components[.query]?.value as? [String: String], ["key": "value"])
        XCTAssertEqual(resolvedReference.components[.headers]?.value as? [String: String], ["key": "value"])
        XCTAssertEqual(resolvedReference.components[.body]?.value as? Data?, nil)
        XCTAssertEqual(resolvedReference.components[.service]?.value as? URLRequest.NetworkServiceType, .default)
        XCTAssertEqual(resolvedReference.components[.cellular]?.value as? Bool, true)
        XCTAssertEqual(resolvedReference.components[.timeout]?.value as? TimeInterval, 60)
        XCTAssertEqual(resolvedReference.components[.constrained]?.value as? Bool, true)
        XCTAssertEqual(resolvedReference.components[.expensive]?.value as? Bool, true)

        XCTAssertEqual(resolvedInherit.components[.method]?.value as? HTTPMethod, .post)
        XCTAssertEqual(resolvedInherit.components[.path]?.value as? String, "path/middle/final")
        XCTAssertEqual(resolvedInherit.components[.query]?.value as? [String: String], ["key": "value"])
        XCTAssertEqual(resolvedInherit.components[.headers]?.value as? [String: String], ["key": "value"])
        XCTAssertEqual(resolvedInherit.components[.body]?.value as? Data?, .init())
        XCTAssertEqual(resolvedInherit.components[.service]?.value as? URLRequest.NetworkServiceType, .background)
        XCTAssertEqual(resolvedInherit.components[.cellular]?.value as? Bool, false)
        XCTAssertEqual(resolvedInherit.components[.timeout]?.value as? TimeInterval, 15)
        XCTAssertEqual(resolvedInherit.components[.constrained]?.value as? Bool, false)
        XCTAssertEqual(resolvedInherit.components[.expensive]?.value as? Bool, false)
    }
}
