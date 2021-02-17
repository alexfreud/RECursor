//
//  Inner.swift
//  TableView
//
//  Created by Александр Васильченко on 16.02.2021.
//

import Foundation

internal typealias DWORD = UInt32

internal struct Inner {
    internal static let riff = "RIFF"
    internal static let list = "LIST"
    internal static let acon = "ACON"
    internal static let info = "INFO"
    internal static let inam = "INAM"
    internal static let iart = "IART"
    internal static let rate = "rate"
    // chunkIds are always four chars, hence the trailing space.
    internal static let seq =  "seq "
    internal static let anih = "anih"
    internal static let fram = "fram"
    internal static let icon = "icon"
}
