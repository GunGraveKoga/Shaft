// Copyright 2024 The Shaft Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CSkia
import Foundation
import Shaft

/// An implementation of ``Renderer`` using Skia as the backend.
public class SkiaGLRenderer: SkiaRenderer, GLRenderer {
    /// Creates a per-view Skia GPU context.
    public func createGLContext() -> GLContext {
        var interface = gr_glinterface_create_native_interface()
        return SkiaGLContext(gr_direct_context_make_gl(&interface))
    }
}

/// A ``GLContext`` backed by a Skia `GrDirectContext`.
public class SkiaGLContext: GLContext {

    private var grDirectContext: GrDirectContext_sp

    init(_ context: GrDirectContext_sp) { self.grDirectContext = context }

    public func createGLCanvas(fbo: UInt, size: ISize) -> DirectCanvas {
        let grGLInfo = GrGLFramebufferInfo(
            fFBOID: 0,
            fFormat: 0x8058,  // UInt32(GL_RGBA8)
            fProtected: skgpu.Protected.no
        )

        let grRenderTarget = GrBackendRenderTargets.MakeGL(
            Int32(size.width),
            Int32(size.height),
            0,
            0,
            grGLInfo
        )

        // let colorSpace = color_space_new_srgb()
        let colorSpace = color_space_new_null()

        let skSurface = SkSurfaces.WrapBackendRenderTarget(
            gr_direct_context_unwrap(&grDirectContext),  // Gr context
            grRenderTarget,  // render target
            GrSurfaceOrigin.init(1),  // GrSurfaceOrigin.kBottomLeft_GrSurfaceOrigin,
            kRGBA_8888_SkColorType,  // color type
            colorSpace,  // colorspace
            nil,  // surface properties
            nil,
            nil
        )

        return SkiaCanvas(skSurface, grDirectContext, size)
    }

    /// Flushes and submits any pending GPU work and releases the context.
    public func dispose() {
        gr_direct_context_flush_and_submit(&grDirectContext, GrSyncCpu.yes)
        grDirectContext.reset()
    }
}
