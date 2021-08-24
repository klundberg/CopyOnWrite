# CopyOnWrite
μframework encapsulating the `CopyOnWrite` type, to make implementing value semantics easy!

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fklundberg%2FCopyOnWrite%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/klundberg/CopyOnWrite)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fklundberg%2FCopyOnWrite%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/klundberg/CopyOnWrite)

[![codecov.io](https://img.shields.io/codecov/c/github/klundberg/CopyOnWrite.svg)](http://codecov.io/github/klundberg/CopyOnWrite)
[![License](https://img.shields.io/cocoapods/l/CopyOnWrite.svg?style=flat)](http://cocoapods.org/pods/CopyOnWrite)


## Why do you need it?

CopyOnWrite is a μframework that provides an abstraction for implementing value-semantics in your structs that contain reference types.

Value semantics is a concept that applies to types where you cannot affect the value of one variable by mutating another variable. Any attempts to change the state of some variable will remain local to that variable. For example, the `String` type is a value type (a struct) with value semantics:

```swift
var s1 = "Foo"
var s2 = s1
s1.append("Bar")
print(s1) // FooBar
print(s2) // Foo
```

The act of assigning `s1` to `s2` effectively makes a copy of the contents of `s1` and stores that copy into `s2` so that changes to one are isolated from the other, which is the critical detail that defines a type as having value semantics.

However, just because `String` is a struct doesn't mean it gets value semantics for free. You must deliberately and intentionally implement this behavior if your struct types contain references inside them, like `String` does. Consider this example:

```swift
class Foo {
  var num: Int = 0
}

struct Bar {
  private var storage = Foo()

  var num: Int {
    return storage.num
  }

  func update(_ num: Int) {
    storage.num = num
  }
}

var bar1 = Bar()
var bar2 = bar1
bar1.update(100)
print(bar1.num) // 100
print(bar2.num) // 100
```

Since the `Bar` struct contains a reference type, the reference is copied when assigning bar1 to bar2, but the instance in memory remains the same, so altering the properties of that instance will affect all references to that instance, which may be unexpected behavior for those who use your types. For more in-depth details, read [this post](http://www.klundberg.com/blog/encapsulating-value-semantics) and check out the resources it references.

You can use this `CopyOnWrite` library to easily implement value semantics so that mutating reference types within your structs will keep those mutations local to the specific variable that struct is stored in, and not any other places the struct may have been stored.

## How does it work?

Altering the prior example in the following way will allow the `Bar` type to have value semantics:

```swift
class Foo {
  var num: Int = 0
}

struct Bar {
  private var storage = CopyOnWrite(reference: Foo(), copier: {
    let new = Foo()
    new.num = $0.num
    return new
  })

  var num: Int {
    return storage.reference.num
  }

  mutating func update(_ num: Int) {
    storage.mutatingReference.num = num
  }
}

var bar1 = Bar()
var bar2 = bar1
bar1.update(100)
print(bar1.num) // 100
print(bar2.num) // 0
```

`CopyOnWrite`'s primary initializer takes two parameters: the object to wrap, and a copier closure that is called only if it determines that it needs to make a copy to preserve value semantics. If you only have one reference that points to the internal reference wrapped by `CopyOnWrite`, the closure does not need to be called, and it will simply update the reference directly as an optimization. As soon as more than one value references the internal storage, `CopyOnWrite` will detect that fact and run the copy closure before mutating the reference:

```swift
var bar3 = Bar()
bar3.update(42) // only one reference, no copy made
var bar4 = bar3
bar3.update(1024) // two references to Bar's internal storage in bar3 and bar4, so run the copy closure before making the change
bar3.update(0) // bar3 has a unique reference now after the previous copy, so it will not copy again
```

## Usage

### Reference access

Once you initialize a copy on write value, you can access the internal reference with two properties:

* `reference` - intended for immutable operations: any property or method that does not change the observable state of your stored reference type can be safely called through this property.
* `mutatingReference` - intended for mutable operations. Anything that does change the observable state of the reference must be called through this property.

As you can see in the example above, the `update` method on `Bar` was changed to be `mutating`. This is because simply accessing `mutatingReference` may cause the reference in `CopyOnWrite` to be reassigned, and so anything that references this property must also be marked mutating which helps guarantee that you cannot accidentally change a value within your reference type if your struct is stored in a `let` constant.

### Caveats

However, it is your responsibility to call the right property at the right time. There is nothing the compiler or this type can do to stop you from doing this:

```swift
func update(_ num: Int) {
  storage.reference.num = num
}
```

While this code will compile, it will cause the original issue to resurface, where calling `update` on one variable will affect the value stored in another.

It is also strongly recommended that your copy on write instance variables be private, so that external clients of your API don't do the wrong thing if they try to access it directly. Provide functions/properties that expose the functionality you want, backed by the referenced object instead.

### Convenience initializers

This library also provides a protocol you can choose to conform to, in case you find yourself duplicating the same copy closure in many places throughout your types:

```swift
public protocol Cloneable: class {
  func clone() -> Self
}
```

If your types can conform to that protocol, you can simply provide the reference to `CopyOnWrite` like so:

```swift
extension Foo: Cloneable {
  func clone() -> Self {
    let new = self.init()
    new.num = num
    return new
  }
}

struct Bar {
  private var storage = CopyOnWrite(reference: Foo())

  // ...
}
```

For types that may conform to `NSCopying` or `NSMutableCopying`, there are convenience initializers for those as well:

```swift
CopyOnWrite(copyingReference: MyNSCopyingType())
CopyOnWrite(mutableCopyingReference: MyNSMutableCopyingType())
```

Take care to use the correct initializer for the right type you want to store. If you use the `NSCopying` version for a type like `NSMutableString`, the `copy` method that gets called will actually create an immutable version, and when you try to call a mutating method on it you will crash your program.

## Requirements

* 1.0.0 is supported on Xcode 9/Swift 4
* 0.9.0 is supported on Xcode 8.0+/Swift 3.0+
* iOS 8+/OS X 10.9+/watchOS 2+/tvOS 9+

## Installation

### CocoaPods

`CopyOnWrite` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'CopyOnWrite', '~> 1.0.0'
```

### Carthage

`CopyOnWrite` can be integrated with [Carthage](https://github.com/Carthage/Carthage). Add the following to your `Cartfile` to use it:

```
github "klundberg/CopyOnWrite" ~> 1.0.0
```

### Swift Package Manager

Add the following line to your dependencies list in your `Package.swift` file:

```
.package(url: "https://github.com/klundberg/CopyOnWrite.git", from: "1.0.0"),
```

### Manual Installation

Simply copy the `CopyOnWrite.swift` file into your project.

## Author

Kevin Lundberg, kevin at klundberg dot com

## Contributions

If you have any changes you'd like to see, please feel free to open a pull request. Please include unit tests for any changes.

## License

CopyOnWrite is available under the MIT license. See the LICENSE file for more info.
