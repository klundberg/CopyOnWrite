//
//  CopyOnWrite.swift
//  CopyOnWrite
//
//  Created by Kevin Lundberg on 2/20/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

fileprivate final class Box<T> {
    let unbox: T
    init(_ value: T) {
        unbox = value
    }
}

public struct CopyOnWrite<T: AnyObject> {

    private var _reference: Box<T>
    private let makeCopy: (T) -> T

    public init(reference: T, copier: @escaping (T) -> T) {
        self._reference = Box(reference)
        self.makeCopy = copier
    }

    public var reference: T {
        return _reference.unbox
    }

    public var mutatingReference: T {
        mutating get {
            // copy the reference only if necessary
            if !isKnownUniquelyReferenced(&_reference) {
                _reference = Box(makeCopy(_reference.unbox))
            }

            return _reference.unbox
        }
    }
}

public protocol Cloneable: class {
    func clone() -> Self
}

extension CopyOnWrite where T: Cloneable {
    public init(reference: T) {
        self.init(reference: reference, copier: { $0.clone() })
    }
}

import Foundation

extension CopyOnWrite where T: NSCopying {
    public init(copyingReference reference: T) {
        self.init(reference: reference, copier: { $0.copy() as! T })
    }
}

extension CopyOnWrite where T: NSMutableCopying {
    public init(mutableCopyingReference reference: T) {
        self.init(reference: reference, copier: { $0.mutableCopy() as! T })
    }
}
