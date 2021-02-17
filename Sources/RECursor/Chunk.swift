//
//  Chunk.swift
//  TableView
//
//  Created by Александр Васильченко on 16.02.2021.
//

// https://www.informit.com/articles/article.aspx?p=1189080&seqNum=3
// https://www.daubnet.com/en/file-format-ani

import Cocoa

internal struct RiffInfo {
    let chunkId: UInt32
    let size: UInt32
    let format: UInt32
}

internal struct ChunkInfo {
    let chunkId: UInt32
    let size: UInt32
}

internal struct Chunk {
    let chunkId: String
    let size: Int
    let range: Range<Int>
    let subChunks: [Chunk]?
}

internal struct AniHeader {
    let cbSize: UInt32       // Data structure size (in bytes)
    let nFrames: UInt32      // Number of images (also known as frames) stored in the file
    let nSteps: UInt32       // Number of frames to be displayed before the animation repeats
    let iWidth: UInt32       // Width of frame (in pixels)
    let iHeight: UInt32      // Height of frame (in pixels)
    let iBitCount: UInt32    // Number of bits per pixel
    let nPlanes: UInt32      // Number of color planes
    let iDispRate: UInt32    // Default frame display rate (measured in 1/60th-of-a-second units)
    let bfAttributes: UInt32 // ANI attribute bit flags
}
