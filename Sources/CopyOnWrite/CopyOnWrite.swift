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
@propertyWrapper
public struct CopyOnWrite<Reference: AnyObject> {

    private var _reference: Box<Reference>
    private let makeCopy: (Reference) -> Reference

    /// Constructs the copy-on-write wrapper around the given reference and copy function
    ///
    /// - Parameters:
    ///   - initialValue: The object that is to be given value semantics
    ///   - copier: The function that is responsible for copying the reference if the consumer of this API needs it to be copied. This function should create a new instance of the referenced type; it should not return the original reference given to it.
    public init(wrappedValue: Reference, copier: @escaping (Reference) -> Reference) {
        self._reference = Box(wrappedValue)
        self.makeCopy = copier
    }

    /// Returns the reference meant for read-only operations.
    public var wrappedValue: Reference {
        get {
            return _reference.unbox
        }
        set {
            _reference = Box(makeCopy(newValue))
        }
    }

    /// Returns the reference meant for mutable operations. If necessary, the reference is copied using the `copier` function or closure provided to the initializer before returning, in order to preserve value semantics.
    public var projectedValue: Reference {
        mutating get {
            // copy the reference only if necessary
            if !isUniquelyReferenced {
                _reference = Box(makeCopy(_reference.unbox))
            }

            return _reference.unbox
        }
        set {
            _reference = Box(makeCopy(newValue))
        }
    }

    /// Helper property to determine whether the reference is uniquely held. Used in tests as a sanity check.
    internal var isUniquelyReferenced: Bool {
        mutating get {
            return isKnownUniquelyReferenced(&_reference)
        }
    }
}

/// Describes reference types that can be copied
public protocol Copyable: class {

    /// Makes a copy of `self` and returns it
    ///
    /// - Returns: A new instance of `self` with all relevant data copied from it.
    func copy() -> Self
}

// MARK: - Cloneable
extension CopyOnWrite where Reference: Copyable {

    /// Constructs the copy-on-write wrapper around the given `Cloneable` reference
    ///
    /// - Parameter reference: A `Cloneable` object which will be copied with `clone()` when it is to be mutated.
    public init(wrappedValue: Reference) {
        self.init(wrappedValue: wrappedValue, copier: { $0.copy() })
    }
}

import Foundation

// MARK: - NSCopying
extension CopyOnWrite where Reference: NSCopying {

    /// Constructs the copy-on-write wrapper around the given `NSCopying` reference
    ///
    /// CAUTION: If `Reference` implements both `NSCopying` and `NSMutableCopying`, make sure you only pass an instance of a type that returns the same type when calling `copy()`, otherwise an attempt to mutate this reference could cause your program to trap.
    ///
    /// - Parameter reference: An `NSCopying` object which will be copied with `copy()` when it is to be mutated.
    public init(copyingReference reference: Reference) {
        self.init(wrappedValue: reference, copier: { $0.copy() as! Reference })
    }
}

// MARK: - NSMutableCopying
extension CopyOnWrite where Reference: NSMutableCopying {

    /// Constructs the copy-on-write wrapper around the given `NSMutableCopying` reference
    ///
    /// CAUTION: If `Reference` implements both `NSCopying` and `NSMutableCopying`, make sure you only pass an instance of a type that returns the same type when calling `mutableCopy()`, otherwise an attempt to mutate this reference could cause your program to trap.
    ///
    /// - Parameter reference: An `NSMutableCopying` object which will be copied with `mutableCopy()` when it is to be mutated.
    public init(mutableCopyingReference reference: Reference) {
        self.init(wrappedValue: reference, copier: { $0.mutableCopy() as! Reference })
    }
}
