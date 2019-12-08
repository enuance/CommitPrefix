//
//  CPDebugPrint.swift
//
//
//  Created by Stephen Martinez on 12/7/19.
//

import Foundation

#if DEBUG
private let isDebugMode = true
#else
private let isDebugMode = false
#endif

/// A Debug Printer that only prints in debug mode
public func cpDebugPrint(_ value: Any, file: String = #file, line: Int = #line, function: String = #function) {
    guard isDebugMode else { return }
    print("/n", "********** Commit Prefix Debug **********")
    print("File: \(file)")
    print("Line: \(line)")
    print("Function: \(function)")
    print("value: ", value)
    print("*****************************************", "/n")
}
