// ----------------------------------------------------------------------------
//
//  Data+Extensions.swift
//
//  @author     Alexander Vasilchenko <avasilchenko@stream.ru>
//  @copyright  Copyright (c) 2020. All rights reserved.
//  @link       https://re-amp.ru/
//  @email      alexfreud@me.com
//
// ----------------------------------------------------------------------------

import Foundation
import Cocoa

internal extension Data {
    var stringValue: String? {
        return String(data: self, encoding: .utf8)
    }

    var integerValue: Int {
        var dataSize: Int = 0
        let sizeData = NSData(bytes: Array(self), length: 4)
        sizeData.getBytes(&dataSize, length: 4)
        return dataSize.littleEndian
    }

    func headerAndSize(with offset: Int) -> (name: String, size: Int)? {
        let headerRange = offset..<offset + 4
        let sizeRange = offset + 4..<offset + 8
        guard count > headerRange.first ?? 0,
              let header = self[headerRange].stringValue else {
            return nil
        }
        let size = self[sizeRange].integerValue
        return (header, size)
    }

    var cursorData: RECursorModel {
        if riffIsValid {
            let data = parseChunks()
            return RECursorModel(displayRate: data.displayRate, frames: data.frames)
        }
        if let cursorImage = NSImage(data: self) {
            let cursor = NSCursor(image: cursorImage, hotSpot: .zero)
            return RECursorModel(displayRate: 0, frames: [cursor])
        }
        return RECursorModel(displayRate: 0, frames: [])
    }

    private var hotSpot: NSPoint {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return .zero
        }
        return NSPoint(x: properties["hotspotX"] as? CGFloat ?? 0,
                       y: properties["hotspotY"] as? CGFloat ?? 0)
    }

    // MARK: - Parse RIFF format

    private var riffIsValid: Bool {
        return count > 12 &&
            self[0..<4].stringValue == "RIFF" &&
            self[8..<12].stringValue == "ACON"
    }

    private func parseChunks() -> (displayRate: Int, frames: [NSCursor]) {
        var displayRate: Int = 0
        var cursorFrames: [NSCursor] = []
        var offset = 12
        while true {
            guard let header = headerAndSize(with: offset) else {
                break
            }
            let beginOfStruct = offset + 8
            switch header.name {
            case "anih":
                displayRate = self[beginOfStruct + 28..<beginOfStruct + 32].integerValue
            case "LIST":
                cursorFrames = parseFrames(with: beginOfStruct)
            default:
                continue
            }
            offset += header.size + 8
        }
        return (displayRate, cursorFrames)
    }

    private func parseFrames(with offset: Int) -> [NSCursor] {
        var frames: [NSCursor] = []
        guard self[offset..<offset + 4].stringValue == "fram" else { return frames }
        var beginIndex = offset + 4
        while true {
            guard let header = headerAndSize(with: beginIndex),
                  header.name.lowercased().contains("icon") else {
                break
            }
            let imageData = self[beginIndex + 8..<beginIndex + 8 + header.size]
            if let image = NSImage(data: imageData) {
                let cursor = NSCursor(image: image, hotSpot: hotSpot)
                frames.append(cursor)
            }
            beginIndex += header.size + 8
        }
        return frames
    }

}
