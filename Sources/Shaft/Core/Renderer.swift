// Copyright 2024 The Shaft Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// A renderer converts high-level drawing operations into low-level drawing
/// commands that can be executed by the underlying graphics API.
public protocol Renderer {
    func createParagraphBuilder(_ style: ParagraphStyle) -> ParagraphBuilder

    func createTextBlob(_ glyphs: [GlyphID], positions: [Offset], font: Font) -> TextBlob

    func decodeImageFromData(_ data: Data) -> AnimatedImage?

    func createPath() -> Path

    var fontCollection: FontCollection { get }
}

/// A handle to a per-view GPU/GL context, used to create canvases that render
/// into an OpenGL framebuffer.
///
/// Each view owns its own context so that Skia's GPU resources are not shared
/// across windows/threads. Call `dispose()` when the view is destroyed.
public protocol GLContext: AnyObject {
    /// Creates a canvas that draws into the framebuffer with id `fbo`.
    func createGLCanvas(fbo: UInt, size: ISize) -> DirectCanvas
    /// Releases the GPU resources held by this context.
    func dispose()
}

public protocol GLRenderer: Renderer {
    /// Creates a new GPU context for a view.
    func createGLContext() -> GLContext
}

#if canImport(Metal)

    import Foundation
    import Metal

    public protocol MetalRenderer: Renderer {
        var device: MTLDevice { get }

        var queue: MTLCommandQueue { get }

        func createMetalCanvas(texture: MTLTexture, size: ISize) -> DirectCanvas

        func createMetalImage(texture: MTLTexture) -> NativeImage

    }

#endif
