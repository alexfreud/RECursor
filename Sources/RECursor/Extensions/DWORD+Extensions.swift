//
//  File.swift
//  
//
//  Created by Александр Васильченко on 17.02.2021.
//

import Foundation

extension DWORD {
    var stringValue: String {
        let byteArray = withUnsafeBytes(of: littleEndian) {
            Array($0)
        }
        return String(cString: byteArray)
            .replacingOccurrences(of: "\0", with: "")
            .replacingOccurrences(of: "\u{01}", with: "")
    }
}
