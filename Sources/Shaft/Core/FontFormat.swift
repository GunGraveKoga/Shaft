import Foundation

/// The binary format of font data, identified by its magic bytes.
public enum FontFormat: Sendable {
    /// TrueType (`0x00010000` / `true`).
    case truetype
    /// OpenType with CFF outlines (`OTTO`).
    case opentype
    /// WOFF 1.0 (`wOFF`).
    case woff
    /// WOFF 2.0 (`wOF2`).
    case woff2
    /// TrueType/OpenType collection (`ttcf`).
    case collection
    /// Unrecognized or too-short data.
    case unknown

    /// Detects the font format from the leading magic bytes of `data`.
    public static func detect(_ data: Data) -> FontFormat {
        guard data.count >= 4 else { return .unknown }

        let tag = data.withUnsafeBytes { raw -> UInt32 in
            UInt32(bigEndian: raw.loadUnaligned(fromByteOffset: 0, as: UInt32.self))
        }

        switch tag {
        case 0x774F_4632: return .woff2       // 'wOF2'
        case 0x774F_4646: return .woff        // 'wOFF'
        case 0x7474_6366: return .collection  // 'ttcf'
        case 0x4F54_544F: return .opentype    // 'OTTO'
        case 0x7472_7565: return .truetype    // 'true'
        case 0x0001_0000: return .truetype    // TrueType
        case 0x0002_0000: return .truetype    // legacy Apple TrueType
        default:          return .unknown
        }
    }
}

extension FontCollection {

    /// Returns the first typeface that loads successfully from `candidates`.
    ///
    /// Candidates are tried in order; formats that the current platform cannot
    /// decode (for example WOFF2 on Windows/Linux) are skipped.
    public func firstValidTypeface(_ candidates: [Data]) -> (any Typeface)? {
        for data in candidates {
            let t = makeTypefaceFrom(data)
            if t.isValid { return t }
        }
        return nil
    }
}
