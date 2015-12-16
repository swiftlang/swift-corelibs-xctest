// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTimeUtilities.swift
//  Some simple functions for working with "time intervals".
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// Returns the number of seconds since the reference time as a Double.
internal func currentTimeIntervalSinceReferenceTime() -> Double {
    var tv = timeval()
    let currentTime = withUnsafeMutablePointer(&tv, { (t: UnsafeMutablePointer<timeval>) -> Double in
        gettimeofday(t, nil)
        return Double(t.memory.tv_sec) + Double(t.memory.tv_usec) / 1000000.0
    })
    return currentTime
}

/// Returns a string version of the given time interval rounded to no more than 3 decimal places.
internal func printableStringForTimeInterval(timeInterval: Double) -> String {
    return String(round(timeInterval * 1000.0) / 1000.0)
}

