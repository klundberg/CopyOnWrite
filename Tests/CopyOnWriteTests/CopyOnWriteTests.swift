//
//  CopyOnWriteTests.swift
//  CopyOnWriteTests
//
//  Created by Kevin Lundberg on 2/20/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

import XCTest
import Foundation
@testable import CopyOnWrite

class CopyOnWriteTests: XCTestCase {

    var values: [CopyOnWrite<Container>] = []

    override func setUp() {
        super.setUp()

        values = [
            CopyOnWrite(reference: Container(), copier: { $0.clone() }),
            CopyOnWrite(reference: Container()),
            CopyOnWrite(copyingReference: Container()),
            CopyOnWrite(mutableCopyingReference: Container()),
        ]
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsUniquelyReferenced() {
        for value in values {
            value.reference.append("foo")

            XCTAssertEqual(value.reference, "foo")
        }
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsNotUniquelyReferenced() {
        for value in values {
            let old = value
            value.reference.append("foo")

            XCTAssertEqual(old.reference, "foo")
        }
    }

    func test_StringDoesNotCopy_WhenAccessingMutableReference_WhileItIsUniquelyReferenced() {
        for var value in values {
            value.mutatingReference.append("foo")

            XCTAssertEqual(value.reference, "foo")
        }
    }

    func test_ReferenceDoesCopy_WhenAccessingMutableReference_WhileItIsNotUniquelyReferenced() {
        for var value in values {
            let old = value
            value.mutatingReference.append("foo")
            
            XCTAssertEqual(old.reference, "")
        }
    }
}
