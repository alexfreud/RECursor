//
//  Errors.swift
//  TableView
//
//  Created by Александр Васильченко on 16.02.2021.
//

import Foundation

internal enum CursorError: LocalizedError {
    case noCursorFile(fileName: String)
    case noCursorData
    case emptyData
    case noRIFFFormat(format: String)
    case noAconFormat(format: String)
    case noChunksData
    case noAnihChunk
    case noFramChunk
    case noIconChunk(format: String)

    var errorDescription: String? {
        switch self {
        case .noCursorFile(let fileName):
            return "Cursor file \(fileName) not found"
        case .noCursorData:
            return "Cursor data is nil"
        case .emptyData:
            return "Cursor data is empty"
        case .noRIFFFormat(let format):
            return "Expected format. Expected \"RIFF\", got \"\(format)\""
        case .noAconFormat(let format):
            return "Expected format. Expected \"ACON\", got \"\(format)\""
        case .noChunksData:
            return "No chunks in file"
        case .noAnihChunk:
            return "No anih chunk found"
        case .noIconChunk(let format):
            return "Unexpected chunk type in fram: \"\(format)\""
        case .noFramChunk:
            return "No fram chunk in file"
        }
    }
}
