// Copyright 2024 The Shaft Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension Duration {
    /// Returns the duration in milliseconds.
    public var inMilliseconds: Int64 {
        return Int64(
            self.components.seconds * 1000 + self.components.attoseconds / 1_000_000_000_000_000
        )
    }

    /// Returns the duration in microseconds.
    public var inMicroseconds: Int64 {
        return Int64(
            self.components.seconds * 1_000_000 + self.components.attoseconds / 1_000_000_000_000
        )
    }

    public var inTimeInterval: TimeInterval {
        let components = self.components
        let seconds = TimeInterval(components.seconds)
        let fractionalSeconds = TimeInterval(components.attoseconds) / 1e18
        return seconds + fractionalSeconds
    }

    /// The number of microseconds per millisecond.
    public static let microsecondsPerMillisecond = 1000

    /// The number of milliseconds per second.
    public static let millisecondsPerSecond = 1000

    /// The number of seconds per minute.
    ///
    /// Notice that some minutes of official clock time might
    /// differ in length because of leap seconds.
    /// The ``Duration`` and ``DateTime`` classes ignore leap seconds
    /// and consider all minutes to have 60 seconds.
    public static let secondsPerMinute = 60

    /// The number of minutes per hour.
    public static let minutesPerHour = 60

    /// The number of hours per day.
    ///
    /// Notice that some days may differ in length because
    /// of time zone changes due to daylight saving.
    /// The ``Duration`` class is time zone agnostic and
    /// considers all days to have 24 hours.
    public static let hoursPerDay = 24

    public static var microsecondsPerSecond: Int64 {
        return 1_000_000
    }
}

extension Date {

    public var millisecondsSinceNow: Int64 {
        let duration = Duration.seconds(self.timeIntervalSinceNow)
        return duration.inMilliseconds
    }

    public var microsecondsSinceNow: Int64 {
        let duration = Duration.seconds(self.timeIntervalSinceNow)
        return duration.inMicroseconds
    }

    public var isDistantFuture: Bool {
        self >= Date.distantFuture.addingTimeInterval(-86400)
    }

    public var isDistantPast: Bool {
        self <= Date.distantPast.addingTimeInterval(86400)
    }
}
