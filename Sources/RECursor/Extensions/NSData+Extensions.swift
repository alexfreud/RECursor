//
//  File.swift
//  
//
//  Created by Александр Васильченко on 17.02.2021.
//

import Foundation
import ImageIO

internal extension Data {
    func object<T>(at index: Index) -> T {
        subdata(in: index ..< index.advanced(by: MemoryLayout<T>.size))
            .withUnsafeBytes { $0.load(as: T.self) }
    }

    var stringValue: String? {
        return String(data: self, encoding: .windowsCP1251)?
            .replacingOccurrences(of: "\0", with: "")
    }

    var arrayValue: [Int] {
        var valuesArray = [UInt32](repeating: 0,
                                        count: count / MemoryLayout<UInt32>.stride)
        _ = valuesArray.withUnsafeMutableBytes { self.copyBytes(to: $0) }
        return valuesArray.map({ Int($0) })
    }

    var hotSpot: NSPoint {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return .zero
        }
        return NSPoint(x: properties["hotspotX"] as? CGFloat ?? 0,
                       y: properties["hotspotY"] as? CGFloat ?? 0)
    }
}
