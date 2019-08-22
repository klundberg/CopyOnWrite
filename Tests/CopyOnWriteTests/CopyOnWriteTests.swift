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

    final class Bar: Copyable {
        var value: Int

        required init(value: Int = 0) {
            self.value = value
        }

        func copy() -> Bar {
            return Bar(value: value)
        }
    }

    struct Foo {
        @CopyOnWrite(copier: { Bar(value: $0.value) }) var bar: Bar = Bar()
    }

    var values: [CopyOnWrite<Container>] = []

    override func setUp() {
        super.setUp()

        values = [
            CopyOnWrite(wrappedValue: Container(), copier: { $0.copy() }),
            CopyOnWrite(wrappedValue: Container()),
            CopyOnWrite(copyingReference: Container()),
            CopyOnWrite(mutableCopyingReference: Container()),
        ]
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsUniquelyReferenced() {
        for index in 0..<values.count {
            XCTAssertTrue(values[index].isUniquelyReferenced) // sanity check

            values[index].wrappedValue.append("foo")

            XCTAssertEqual(values[index].wrappedValue, "foo")
            XCTAssertTrue(values[index].isUniquelyReferenced)
        }
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsNotUniquelyReferenced() {
        for index in 0..<values.count  {
            let old = values[index]

            XCTAssertFalse(values[index].isUniquelyReferenced) // sanity check, storing in `old` should make the reference held twice

            values[index].wrappedValue.append("foo")

            XCTAssertEqual(old.wrappedValue, "foo")
            XCTAssertFalse(values[index].isUniquelyReferenced) // immutable reference doesn't copy on edit, so same reference remaines held by both variables
        }
    }

    func test_StringDoesNotCopy_WhenAccessingMutableReference_WhileItIsUniquelyReferenced() {
        for index in 0..<values.count  {
            XCTAssertTrue(values[index].isUniquelyReferenced) // sanity check

            values[index].projectedValue.append("foo")

            XCTAssertEqual(values[index].wrappedValue, "foo")
            XCTAssertTrue(values[index].isUniquelyReferenced)
        }
    }

    func test_ReferenceDoesCopy_WhenAccessingMutableReference_WhileItIsNotUniquelyReferenced() {
        for index in 0..<values.count  {
            let old = values[index]

            XCTAssertFalse(values[index].isUniquelyReferenced) // sanity check, storing in `old` should make the reference held twice

            values[index].projectedValue.append("foo")

            XCTAssertEqual(old.wrappedValue, "")
            XCTAssertTrue(values[index].isUniquelyReferenced)
        }
    }
}
