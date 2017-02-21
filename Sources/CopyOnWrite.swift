//
//  CopyOnWrite.swift
//  CopyOnWrite
//
//  Created by Kevin Lundberg on 2/20/17.
//  Copyright © 2017 Kevin Lundberg. All rights reserved.
//

private final class Box<Boxed> {
    let unbox: Boxed
    init(_ value: Boxed) {
        unbox = value
    }
}

/// Encapsulates behavior surrounding value semantics and copy-on-write behavior
public struct CopyOnWrite<T: AnyObject> {

    private var _reference: Box<T>
    private let makeCopy: (T) -> T

    /// Constructs the copy-on-write wrapper around the given reference and copy function
    ///
    /// - Parameters:
    ///   - reference: The object that is to be given value semantics
    ///   - copier: The function that is responsible for copying the reference if the consumer of this API needs it to be copied. This function should create a new instance of the referenced type; it should not return the original reference given to it.
    public init(reference: T, copier: @escaping (T) -> T) {
        self._reference = Box(reference)
        self.makeCopy = copier
    }

    /// Returns the reference meant for reading only.
    public var reference: T {
        return _reference.unbox
    }

    /// Returns the reference meant for mutating. If necessary, the reference is copied using the function or closure provided to the initializer before returning, in order to preserve value semantics.
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

/// Describes reference types that can be copied
public protocol Cloneable: class {

    /// Makes a copy of `self` and returns it
    ///
    /// - Returns: A new instance of `self` with all relevant data copied from it.
    func clone() -> Self
}

// MARK: - Cloneable
extension CopyOnWrite where T: Cloneable {

    /// Constructs the copy-on-write wrapper around the given `Cloneable` reference
    ///
    /// - Parameter reference: A `Cloneable` object which will be copied with `clone()` when it is to be mutated.
    public init(reference: T) {
        self.init(reference: reference, copier: { $0.clone() })
    }
}

import Foundation

// MARK: - NSCopying
extension CopyOnWrite where T: NSCopying {

    /// Constructs the copy-on-write wrapper around the given `NSCopying` reference
    ///
    /// CAUTION: If `T` implements both `NSCopying` and `NSMutableCopying`, make sure you only pass an instance of a type that returns the same type when calling `copy()`, otherwise an attempt to mutate this reference could cause your program to trap.
    ///
    /// - Parameter reference: An `NSCopying` object which will be copied with `copy()` when it is to be mutated.
    public init(copyingReference reference: T) {
        self.init(reference: reference, copier: { $0.copy() as! T })
    }
}

// MARK: - NSMutableCopying
extension CopyOnWrite where T: NSMutableCopying {

    /// Constructs the copy-on-write wrapper around the given `NSMutableCopying` reference
    ///
    /// CAUTION: If `T` implements both `NSCopying` and `NSMutableCopying`, make sure you only pass an instance of a type that returns the same type when calling `mutableCopy()`, otherwise an attempt to mutate this reference could cause your program to trap.
    ///
    /// - Parameter reference: An `NSMutableCopying` object which will be copied with `mutableCopy()` when it is to be mutated.
    public init(mutableCopyingReference reference: T) {
        self.init(reference: reference, copier: { $0.mutableCopy() as! T })
    }
}
