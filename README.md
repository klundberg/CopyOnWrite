# CopyOnWrite
μframework encapsulating the `CopyOnWrite` type, to make implementing value semantics easy!

[![CI Status](http://img.shields.io/travis/klundberg/CopyOnWrite.svg?style=flat)](https://travis-ci.org/klundberg/CopyOnWrite)
[![Version](https://img.shields.io/cocoapods/v/CopyOnWrite.svg?style=flat)](http://cocoapods.org/pods/CopyOnWrite)
[![codecov.io](https://img.shields.io/codecov/c/github/klundberg/CopyOnWrite.svg)](http://codecov.io/github/klundberg/CopyOnWrite)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange.svg?style=flat)](https://swift.org/package-manager/)
[![License](https://img.shields.io/cocoapods/l/CopyOnWrite.svg?style=flat)](http://cocoapods.org/pods/CopyOnWrite)
[![Platform](https://img.shields.io/cocoapods/p/CopyOnWrite.svg?style=flat)](http://cocoapods.org/pods/CopyOnWrite)

## How it works

CopyOnWrite is a μframework that provides an abstraction for implementing value-semantics in your structs that contain reference types.

Value semantics (in short) is behavior where modifying a value's inner state will only change the value stored in the variable you are currently accessing. Assigning your value to other variables or passing them as function parameters will create a copy of everything in that struct, which means that unless the things being copied are references, you cannot alter that copy without mutating it directly.
