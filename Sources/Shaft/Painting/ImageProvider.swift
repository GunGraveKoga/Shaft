// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright 2024 The Shaft Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Fetch
import Foundation

/// Configuration information passed to the [ImageProvider.resolve] method to
/// select a specific image.
public struct ImageConfiguration: Equatable {
    /// Creates an object holding the configuration information for an [ImageProvider].
    ///
    /// All the arguments are optional. Configuration information is merely
    /// advisory and best-effort.
    public init(
        // bundle: AssetBundle? = nil,
        devicePixelRatio: Float? = nil,
        // locale: Locale? = nil,
        textDirection: TextDirection? = nil,
        size: Size? = nil
            // platform: TargetPlatform? = nil
    ) {
        // self.bundle = bundle
        self.devicePixelRatio = devicePixelRatio
        // self.locale = locale
        self.textDirection = textDirection
        self.size = size
        // self.platform = platform
    }

    /// The preferred [AssetBundle] to use if the [ImageProvider] needs one and
    /// does not have one already selected.
    //   let bundle: AssetBundle?

    /// The device pixel ratio where the image will be shown.
    let devicePixelRatio: Float?

    /// The language and region for which to select the image.
    //   let locale: ui.Locale?

    /// The reading direction of the language for which to select the image.
    let textDirection: TextDirection?

    /// The size at which the image will be rendered.
    let size: Size?

    /// The [TargetPlatform] for which assets should be used. This allows images
    /// to be specified in a platform-neutral fashion yet use different assets on
    /// different platforms, to match local conventions e.g. for color matching or
    /// shadows.
    //   let platform: TargetPlatform?

    /// An image configuration that provides no additional information.
    ///
    /// Useful when resolving an [ImageProvider] without any context.
    static var empty: Self { Self() }

    public func copyWith(
        // bundle: AssetBundle? = nil,
        devicePixelRatio: Float? = nil,
        // locale: Locale? = nil,
        textDirection: TextDirection? = nil,
        size: Size? = nil
            // platform: TargetPlatform? = nil
    ) -> Self {
        Self(
            // bundle: bundle ?? self.bundle,
            devicePixelRatio: devicePixelRatio ?? self.devicePixelRatio,
            // locale: locale ?? self.locale,
            textDirection: textDirection ?? self.textDirection,
            size: size ?? self.size
                // platform: platform ?? self.platform
        )
    }
}

public protocol ImageProvider: Equatable {
    /// Resolves this provider into a stream of decoded images.
    ///
    /// The stream throws an ``ImageProviderError`` (or a transport error from
    /// `fetch`) if the image could not be loaded or decoded.
    func resolve(configuration: ImageConfiguration) -> AsyncThrowingStream<NativeImage, Error>

    func isEqualTo(_ other: any ImageProvider) -> Bool
}

/// Errors that can occur while resolving an ``ImageProvider``.
public enum ImageProviderError: Error, CustomStringConvertible {
    /// The downloaded/in-memory data could not be decoded into an image.
    case decodeFailed(url: URL?)

    /// A human-readable description of the error.
    public var description: String {
        switch self {
        case .decodeFailed(let url):
            return "Failed to decode image data\(url.map { " from \($0.absoluteString)" } ?? "")"
        }
    }
}

extension ImageProvider {
    public func isEqualTo(_ other: any ImageProvider) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

// Decode and stream an image from a data provider.
private func decodeAndStreamImage(from url: URL?, dataProvider: @escaping @Sendable () async throws -> Data)
    -> AsyncThrowingStream<NativeImage, Error>
{
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                let data = try await dataProvider()
                guard let animatedImage = backend.renderer.decodeImageFromData(data) else {
                    throw ImageProviderError.decodeFailed(url: url)
                }
                while let frame = animatedImage.getNextFrame() {
                    continuation.yield(frame.image)
                    guard let duration = frame.duration else { break }
                    try Task.checkCancellation()
                    try await Task.sleep(for: duration)
                }
                continuation.finish()
            } catch is CancellationError {
                continuation.finish()
            } catch {
                NSLog("[ImageProvider] fetch failed: \(error)")
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

public struct NetworkImage: Equatable, ImageProvider, Sendable {
    public init(url: URL) {
        self.url = url
    }

    public let url: URL

    public func resolve(configuration: ImageConfiguration) -> AsyncThrowingStream<NativeImage, Error> {
        decodeAndStreamImage(from: self.url) { try await fetch(self.url) }
    }
}

public struct MemoryImage: Equatable, ImageProvider, Sendable {
    public init(data: Data) {
        self.data = data
    }

    public let data: Data

    public func resolve(configuration: ImageConfiguration) -> AsyncThrowingStream<NativeImage, Error> {
        decodeAndStreamImage(from: nil) { self.data }
    }
}
