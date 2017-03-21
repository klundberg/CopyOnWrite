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
            CopyOnWrite(Container(), copier: { $0.clone() }),
            CopyOnWrite(Container()),
            CopyOnWrite(copyingReference: Container()),
            CopyOnWrite(mutableCopyingReference: Container()),
        ]
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsUniquelyReferenced() {
        for index in 0..<values.count {
            XCTAssertTrue(values[index].isUniquelyReferenced) // sanity check

            values[index].reference.append("foo")

            XCTAssertEqual(values[index].reference, "foo")
            XCTAssertTrue(values[index].isUniquelyReferenced)
        }
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsNotUniquelyReferenced() {
        for index in 0..<values.count  {
            let old = values[index]

            XCTAssertFalse(values[index].isUniquelyReferenced) // sanity check, storing in `old` should make the reference held twice

            values[index].reference.append("foo")

            XCTAssertEqual(old.reference, "foo")
            XCTAssertFalse(values[index].isUniquelyReferenced) // immutable reference doesn't copy on edit, so same reference remaines held by both variables
        }
    }

    func test_StringDoesNotCopy_WhenAccessingMutableReference_WhileItIsUniquelyReferenced() {
        for index in 0..<values.count  {
            XCTAssertTrue(values[index].isUniquelyReferenced) // sanity check

            values[index].mutatingReference.append("foo")

            XCTAssertEqual(values[index].reference, "foo")
            XCTAssertTrue(values[index].isUniquelyReferenced)
        }
    }

    func test_ReferenceDoesCopy_WhenAccessingMutableReference_WhileItIsNotUniquelyReferenced() {
        for index in 0..<values.count  {
            let old = values[index]

            XCTAssertFalse(values[index].isUniquelyReferenced) // sanity check, storing in `old` should make the reference held twice

            values[index].mutatingReference.append("foo")

            XCTAssertEqual(old.reference, "")
            XCTAssertTrue(values[index].isUniquelyReferenced)
        }
    }
}
