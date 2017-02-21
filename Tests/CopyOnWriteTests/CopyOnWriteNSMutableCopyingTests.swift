//
//  CopyOnWriteNSMutableCopyingTests.swift
//  CopyOnWrite
//
//  Created by Kevin Lundberg on 2/21/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

import XCTest
import Foundation
@testable import CopyOnWrite

class CopyOnWriteNSMutableCopyingTests: XCTestCase {

    var copyonwrite: CopyOnWrite<NSMutableString>!

    override func setUp() {
        super.setUp()

        copyonwrite = CopyOnWrite(mutableCopyingReference: NSMutableString())
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsUniquelyReferenced() {
        copyonwrite.reference.append("foo")

        XCTAssertEqual(copyonwrite.reference, "foo")
    }

    func test_StringDoesNotCopy_WhenAccessingImmutableReference_WhileItIsNotUniquelyReferenced() {
        let old = copyonwrite!
        copyonwrite.reference.append("foo")

        XCTAssertEqual(old.reference, "foo")
    }

    func test_StringDoesNotCopy_WhenAccessingMutableReference_WhileItIsUniquelyReferenced() {
        copyonwrite.mutatingReference.append("foo")

        XCTAssertEqual(copyonwrite.reference, "foo")
    }

    func test_ReferenceDoesCopy_WhenAccessingMutableReference_WhileItIsNotUniquelyReferenced() {
        let old = copyonwrite!
        copyonwrite.mutatingReference.append("foo")
        
        XCTAssertEqual(old.reference, "")
    }
}
