//
//  Container.swift
//  CopyOnWrite
//
//  Created by Kevin Lundberg on 2/21/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

import Foundation
import CopyOnWrite

/// Helper class to test copying NSCopying and Cloneable paths in CopyOnWrite
final class Container: NSObject, ExpressibleByStringLiteral {
    var value: String

    required init(value: String = "") {
        self.value = value
    }

    func append(_ string: String) {
        value.append(string)
    }

    override func isEqual(_ object: Any?) -> Bool {
        return (object as? Container)?.value == value
    }

    convenience required init(stringLiteral value: String) {
        self.init(value: value)
    }

    convenience required init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    convenience required init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Container: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Container(value: self.value)
    }
}

extension Container: NSMutableCopying {
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        return Container(value: self.value)
    }
}

extension Container: Copyable {
    func copy() -> Self {
        return type(of: self).init(value: self.value)
    }
}
